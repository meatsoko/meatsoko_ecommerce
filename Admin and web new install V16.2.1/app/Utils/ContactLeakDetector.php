<?php

namespace App\Utils;

class ContactLeakDetector
{
    /**
     * Patterns for content that looks like an attempt to move a deal off-platform:
     * phone numbers, WhatsApp/Telegram links, and "call/text me" phrasing.
     * Intentionally permissive (flags rather than blocks) — false positives here
     * cost less than a missed off-platform handoff, and every flag still goes
     * through human admin review before any consequence.
     *
     * @var array<string, string>
     */
    private const PATTERNS = [
        'phone_number' => '/(?:\+?\d[\s.-]?){7,15}/',
        'whatsapp_link' => '/(?:wa\.me|whatsapp\.com|api\.whatsapp)/i',
        'telegram_link' => '/(?:t\.me|telegram\.me)/i',
        'call_me_phrasing' => '/\b(call|text|whatsapp|reach)\s+me\s+(on|at)\b/i',
    ];

    /**
     * @return string|null the matched reason key, or null if the message looks clean
     */
    public static function scan(?string $message): ?string
    {
        if (blank($message)) {
            return null;
        }

        foreach (self::PATTERNS as $reason => $pattern) {
            if (preg_match($pattern, $message) === 1) {
                return $reason;
            }
        }

        return null;
    }
}
