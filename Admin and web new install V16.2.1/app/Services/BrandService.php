<?php

namespace App\Services;

use App\Models\Brand;
use App\Traits\FileManagerTrait;
use App\Traits\GeneratesUniqueSlug;
use Rap2hpoutre\FastExcel\FastExcel;

class BrandService
{
    use FileManagerTrait, GeneratesUniqueSlug;

    public function getAddData(object $request): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $name = $request['name'][array_search('en', $request['lang'])];
        return [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'brand'),
            'image' => $this->upload('brand/', 'webp', $request->file('image')),
            'image_storage_type' => $request->has('image') ? $storage : null,
            'image_alt_text' => $request['image_alt_text'] ?? null,
            'status' => $request['status'] ?? 0,
        ];
    }

    public function getUpdateData(object $request, object $data): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $image = $request->file('image') ? $this->update('brand/', $data['image'],'webp', $request->file('image')) : $data['image'];
        $name = $request->name[array_search('en', $request['lang'])];
        return  [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'brand', id: $data['id']),
            'status' => $request['status'],
            'image' => $image,
            'image_storage_type' => $request->file('image') ? $storage : $data['image_storage_type'],
            'image_alt_text' => $request['image_alt_text']?? $data['image_alt_text' ],
        ];
    }

    public function deleteImage(object $data): bool
    {
        if ($data['image']) {$this->delete('profile/'.$data['image']);}
        return true;
    }

    public function getImportBulkBrandData(object $request): array
    {
        try {
            $collections = (new FastExcel)->import($request->file('brands_file'));
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

        $columnKey = ['name', 'image_alt_text', 'status'];
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
            if ($name === '') {
                $errors[] = translate('row') . ' ' . $rowNumber . ': ' . translate('brand_name_is_required');
                continue;
            }

            $duplicateKey = mb_strtolower($name);
            if (isset($staged[$duplicateKey]) || Brand::whereRaw('LOWER(name) = ?', [$duplicateKey])->exists()) {
                $errors[] = translate('row') . ' ' . $rowNumber . ': ' . translate('The_brand_has_already_been_taken');
                continue;
            }
            $staged[$duplicateKey] = true;

            $status = $collection['status'] ?? 1;
            $rows[] = [
                'name' => $name,
                'slug' => $this->generateModelUniqueSlug(name: $name, type: 'brand'),
                'image_alt_text' => trim((string)($collection['image_alt_text'] ?? '')) ?: null,
                'status' => in_array((string)$status, ['0', 'false'], true) ? 0 : 1,
            ];
        }

        return [
            'status' => true,
            'message' => count($rows) . ' ' . translate('imported_successfully'),
            'rows' => $rows,
            'errors' => $errors,
        ];
    }

    public function getImportTemplateSample(): array
    {
        return [
            ['name' => 'Sample Brand', 'image_alt_text' => 'Sample brand logo', 'status' => 1],
        ];
    }

}
