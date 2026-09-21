<?php

namespace App\Utils;

use DOMDocument;
use DOMElement;
use DOMNode;

/**
 * Prepares a Business Page description for the public storefront view.
 *
 * The admin editor is Quill, a rich-text editor. When HTML *source* is pasted
 * into it (for example copied out of a code editor), Quill does not treat it as
 * markup: it stores it as text, entity-escaped and wrapped in one <p> per line,
 * often with syntax-highlight <span style="…"> wrappers carried over from the
 * clipboard. The views print the description raw, so the page shows literal
 * "<h2>…</h2>" text. That is what happened to the delete-account page.
 *
 * Pages whose description is ordinary Quill output — every page that already
 * rendered correctly — are returned byte-for-byte unchanged, so their output
 * path is exactly what it was. Only a description whose *visible text* is
 * itself HTML is recovered, and the recovered markup never reaches the page
 * without going through the strict allowlist in {@see sanitize()}: the escaped
 * text was inert until now, and decoding it must not turn it into a way to
 * inject script.
 */
class BusinessPageContent
{
    /** Elements kept as-is (with their children). */
    private const ALLOWED_TAGS = ['h2', 'h3', 'p', 'ol', 'ul', 'li', 'strong', 'em', 'a', 'br'];

    /** Elements removed together with everything inside them. */
    private const DROPPED_TAGS = [
        'script', 'style', 'iframe', 'frame', 'frameset', 'object', 'embed', 'applet',
        'svg', 'math', 'template', 'noscript', 'form', 'input', 'button', 'textarea',
        'select', 'option', 'head', 'title', 'meta', 'link', 'base',
    ];

    /** Link schemes allowed in <a href>. Anything else loses its href. */
    private const ALLOWED_SCHEMES = ['https', 'mailto', 'tel'];

    public static function render(?string $description): string
    {
        $description = (string) $description;
        if (!self::isEscapedMarkup($description)) {
            return $description;
        }

        return self::sanitize(self::recoverMarkup($description));
    }

    /**
     * True when the text a visitor would see contains a paired, allowlisted HTML
     * tag — "<h2 …>" together with "</h2>". Real prose (a privacy policy that
     * mentions "a < b", say) does not produce an opening and closing tag pair,
     * so ordinary pages never take this path.
     */
    private static function isEscapedMarkup(string $description): bool
    {
        if (!str_contains($description, '&lt;')) {
            return false;
        }

        $visibleText = html_entity_decode(strip_tags($description), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $tags = implode('|', self::ALLOWED_TAGS);

        return preg_match('~<(' . $tags . ')\b[^>]*>~i', $visibleText, $open) === 1
            && preg_match('~</' . preg_quote($open[1], '~') . '\s*>~i', $visibleText) === 1;
    }

    /**
     * Turns Quill's escaped-text storage back into the HTML source that was
     * pasted: one line per Quill paragraph, wrappers dropped, entities decoded,
     * HTML comments (such as an authoring note pasted along with the markup)
     * removed.
     */
    private static function recoverMarkup(string $description): string
    {
        $text = preg_replace('~<br\s*/?>|</p\s*>~i', "\n", $description);
        $text = html_entity_decode(strip_tags($text), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = str_replace("\u{00A0}", ' ', $text);

        return preg_replace('~<!--.*?(-->|$)~s', '', $text);
    }

    /**
     * Allowlist sanitizer: keeps {@see ALLOWED_TAGS}, removes {@see DROPPED_TAGS}
     * with their content, unwraps anything else, strips every attribute except
     * a safe <a href>, and drops comments.
     */
    private static function sanitize(string $html): string
    {
        if (trim($html) === '') {
            return '';
        }

        $document = new DOMDocument('1.0', 'UTF-8');
        $previous = libxml_use_internal_errors(true);
        $document->loadHTML(
            // The wrapper gives libxml a single root, which NOIMPLIED needs;
            // being the first element, it is always the outermost <div>.
            '<?xml encoding="UTF-8"?><div>' . $html . '</div>',
            LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD | LIBXML_NONET
        );
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        $root = $document->getElementsByTagName('div')->item(0);
        if (!$root) {
            return e(strip_tags($html));
        }

        self::cleanChildren($root);

        $output = '';
        foreach ($root->childNodes as $child) {
            $output .= $document->saveHTML($child);
        }

        return trim($output);
    }

    private static function cleanChildren(DOMNode $parent): void
    {
        // Copy first: the loop body removes and replaces nodes.
        foreach (iterator_to_array($parent->childNodes) as $node) {
            if ($node->nodeType === XML_TEXT_NODE) {
                continue;
            }

            if (!$node instanceof DOMElement) {
                // Comments, processing instructions, CDATA.
                $parent->removeChild($node);
                continue;
            }

            $tag = strtolower($node->tagName);

            if (in_array($tag, self::DROPPED_TAGS, true)) {
                $parent->removeChild($node);
                continue;
            }

            self::cleanChildren($node);

            if (!in_array($tag, self::ALLOWED_TAGS, true)) {
                while ($node->firstChild) {
                    $parent->insertBefore($node->firstChild, $node);
                }
                $parent->removeChild($node);
                continue;
            }

            self::cleanAttributes($node, $tag);
        }
    }

    private static function cleanAttributes(DOMElement $element, string $tag): void
    {
        $href = $tag === 'a' ? self::safeHref($element->getAttribute('href')) : null;

        foreach (iterator_to_array($element->attributes) as $attribute) {
            $element->removeAttribute($attribute->nodeName);
        }

        if ($href !== null) {
            $element->setAttribute('href', $href);
            if (str_starts_with($href, 'https:')) {
                $element->setAttribute('rel', 'noopener noreferrer');
            }
        }
    }

    /**
     * Returns the href when its scheme is https, mailto or tel, otherwise null.
     * Whitespace and control characters are removed before the scheme is read,
     * which is what defeats "java\tscript:"-style obfuscation.
     */
    private static function safeHref(string $href): ?string
    {
        $href = preg_replace('~[\x00-\x20\x7F]+~u', '', $href);
        if ($href === null || $href === '' || !preg_match('~^([a-z][a-z0-9+.\-]*):~i', $href, $match)) {
            return null;
        }

        $scheme = strtolower($match[1]);
        if (!in_array($scheme, self::ALLOWED_SCHEMES, true)) {
            return null;
        }

        return match ($scheme) {
            'https' => filter_var($href, FILTER_VALIDATE_URL) !== false ? $href : null,
            'tel' => preg_match('~^tel:\+?[0-9().\-]+$~i', $href) === 1 ? $href : null,
            'mailto' => preg_match('~^mailto:[^<>"\'\s]+$~i', $href) === 1 ? $href : null,
        };
    }
}
