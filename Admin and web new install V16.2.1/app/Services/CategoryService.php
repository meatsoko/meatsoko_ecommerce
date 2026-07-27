<?php

namespace App\Services;

use App\Models\Category;
use App\Traits\FileManagerTrait;
use App\Traits\GeneratesUniqueSlug;
use Illuminate\Support\Str;
use Rap2hpoutre\FastExcel\FastExcel;

class CategoryService
{
    use FileManagerTrait, GeneratesUniqueSlug;

    public function getAddData(object $request): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $name = $request['name'][array_search('en', $request['lang'])];

        return [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'category'),
            'icon' => $this->upload('category/', 'webp', $request->file('image')),
            'icon_storage_type' => $request->has('image') ? $storage : null,
            'parent_id' => $request->get('parent_id', 0),
            'position' => $request['position'] ?? 0,
            'priority' => $request['priority'] ?? 0,
            'home_status' => 1,
        ];
    }

    public function getUpdateData(object $request, object $data): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $image = $request->file('image') ? $this->update('category/', $data['image'], 'webp', $request->file('image')) : $data['icon'];
        $name = $request['name'][array_search('en', $request['lang'])];

        $result = [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'category', id: $data['id']),
            'icon' => $image,
            'icon_storage_type' => $request->has('image') ? $storage : $data['icon_storage_type'],
            'priority' => $request['priority'],
        ];

        if ($request['parent_id']) {
            $result['parent_id'] = $request['parent_id'];
        }
        if ($data['position'] == 0) {
            $result['home_status'] = $request['home_status'] ?? 0;
        }
        return $result;
    }

    public function getImportBulkCategoryData(object $request, int $position): array
    {
        try {
            $collections = (new FastExcel)->import($request->file('categories_file'));
        } catch (\Exception) {
            return [
                'status' => false,
                'message' => translate('you_have_uploaded_a_wrong_format_file') . ', ' . translate('please_upload_the_right_file'),
                'rows' => [],
                'errors' => [],
            ];
        }

        if (count($collections) <= 0) {
            return [
                'status' => false,
                'message' => translate('you_need_to_upload_with_proper_data'),
                'rows' => [],
                'errors' => [],
            ];
        }

        $columnKey = match ($position) {
            1 => ['name', 'category_id', 'category_name', 'priority', 'status'],
            2 => ['name', 'category_id', 'category_name', 'sub_category_id', 'sub_category_name', 'priority', 'status'],
            default => ['name', 'priority', 'status'],
        };

        $rows = [];
        $errors = [];
        $staged = [];
        $rowNumber = 1;

        foreach ($collections as $collection) {
            $rowNumber++;

            foreach (array_keys($collection) as $key) {
                if ($key != '' && !in_array($key, $columnKey)) {
                    return [
                        'status' => false,
                        'message' => translate('Please_upload_the_correct_format_file'),
                        'rows' => [],
                        'errors' => [],
                    ];
                }
            }

            $name = trim((string)($collection['name'] ?? ''));
            $priority = $collection['priority'] ?? null;

            if ($name === '') {
                $errors[] = translate('row') . ' ' . $rowNumber . ': ' . translate('category_name_is_required');
                continue;
            }
            if ($priority === null || $priority === '' || !is_numeric($priority)) {
                $errors[] = translate('row') . ' ' . $rowNumber . ': ' . translate('category_priority_is_required');
                continue;
            }

            $parentId = 0;
            if ($position >= 1) {
                [$parentCategory, $error] = $this->resolveCategoryReference($collection, 'category_id', 'category_name', 0, 0, 'category');
                if (!$parentCategory) {
                    $errors[] = translate('row') . ' ' . $rowNumber . ': ' . $error;
                    continue;
                }
                $parentId = $parentCategory->id;
            }

            if ($position == 2) {
                [$subCategory, $error] = $this->resolveCategoryReference($collection, 'sub_category_id', 'sub_category_name', 1, $parentId, 'sub_category');
                if (!$subCategory) {
                    $errors[] = translate('row') . ' ' . $rowNumber . ': ' . $error;
                    continue;
                }
                $parentId = $subCategory->id;
            }

            $duplicateKey = mb_strtolower($name) . '|' . $position . '|' . $parentId;
            if (isset($staged[$duplicateKey]) || Category::where(['name' => $name, 'position' => $position, 'parent_id' => $parentId])->exists()) {
                $errors[] = translate('row') . ' ' . $rowNumber . ': ' . translate('The_category_has_already_been_taken');
                continue;
            }
            $staged[$duplicateKey] = true;

            $status = $collection['status'] ?? 1;
            $rows[] = [
                'name' => $name,
                'slug' => $this->generateModelUniqueSlug(name: $name, type: 'category'),
                'icon' => null,
                'icon_storage_type' => null,
                'parent_id' => $parentId,
                'position' => $position,
                'priority' => (int)$priority,
                'home_status' => in_array((string)$status, ['0', 'false'], true) ? 0 : 1,
            ];
        }

        return [
            'status' => true,
            'message' => count($rows) . ' ' . translate('imported_successfully'),
            'rows' => $rows,
            'errors' => $errors,
        ];
    }

    /**
     * Resolve a parent category/sub-category referenced by a bulk-import row, by id if given, otherwise by
     * case-insensitive name lookup scoped to $position (and $parentId for sub-categories).
     *
     * @return array{0: ?Category, 1: ?string} [matched category or null, error message or null]
     */
    private function resolveCategoryReference(array $collection, string $idColumn, string $nameColumn, int $position, int $parentId, string $label): array
    {
        $id = trim((string)($collection[$idColumn] ?? ''));
        if ($id !== '') {
            $query = Category::where(['id' => $id, 'position' => $position]);
            if ($position >= 1) {
                $query->where('parent_id', $parentId);
            }
            $found = $query->first();
            return [$found, $found ? null : translate('no_' . $label . '_found_with_the_given_id')];
        }

        $name = trim((string)($collection[$nameColumn] ?? ''));
        if ($name === '') {
            return [null, translate('the_' . $label . '_name_column_is_required')];
        }

        $query = Category::where('position', $position)->whereRaw('LOWER(name) = ?', [mb_strtolower($name)]);
        if ($position >= 1) {
            $query->where('parent_id', $parentId);
        }
        $matches = $query->get();

        return match ($matches->count()) {
            0 => [null, translate('no_' . $label . '_found_named') . " \"{$name}\""],
            1 => [$matches->first(), null],
            default => [null, translate('multiple_' . $label . '_rows_are_named') . " \"{$name}\", " . translate('please_rename_one_or_use_the_id_column_instead')],
        };
    }

    public function getImportTemplateSample(int $position): array
    {
        return match ($position) {
            1 => [
                ['name' => 'Sample Sub Category', 'category_name' => optional(Category::where('position', 0)->first())->name ?? 'Existing Category Name', 'priority' => 1, 'status' => 1],
            ],
            2 => [
                ['name' => 'Sample Sub Sub Category', 'category_name' => optional(Category::where('position', 0)->first())->name ?? 'Existing Category Name', 'sub_category_name' => optional(Category::where('position', 1)->first())->name ?? 'Existing Sub Category Name', 'priority' => 1, 'status' => 1],
            ],
            default => [
                ['name' => 'Sample Category', 'priority' => 1, 'status' => 1],
            ],
        };
    }

    public function getSelectOptionHtml(object $data): string
    {
        $output = '<option value="" disabled selected>' . (translate('select_sub_category')) . '</option>';
        foreach ($data as $row) {
            $output .= '<option value="' . $row->id . '">' . $row->defaultName . '</option>';
        }
        return $output;
    }

    public function deleteImages(object $data): bool
    {
        if ($data->childes) {
            foreach ($data->childes as $child) {
                if ($child->childes) {
                    foreach ($child->childes as $item) {
                        if ($item['icon']) {
                            $this->delete('category/' . $item['icon']);
                        }
                    }
                }
                if ($child['icon']) {
                    $this->delete('category/' . $child['icon']);
                }
            }
        }
        if ($data['icon']) {
            $this->delete('category/' . $data['icon']);
        }
        return true;
    }
}
