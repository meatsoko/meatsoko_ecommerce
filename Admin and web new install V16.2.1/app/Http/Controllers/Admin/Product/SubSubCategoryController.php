<?php

namespace App\Http\Controllers\Admin\Product;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\SeoMetaInfoRepositoryInterface;
use App\Contracts\Repositories\TranslationRepositoryInterface;
use App\Exports\CategoryListExport;
use App\Http\Controllers\BaseController;
use App\Http\Requests\Admin\CategoryUpdateRequest;
use App\Http\Requests\Admin\SubCategoryAddRequest;
use App\Services\CategoryService;
use App\Services\SeoMetaInfoService;
use App\Traits\PaginatorTrait;
use Devrabiul\ToastMagic\Facades\ToastMagic;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use Rap2hpoutre\FastExcel\FastExcel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class SubSubCategoryController extends BaseController
{
    use PaginatorTrait;

    public function __construct(
        private readonly CategoryRepositoryInterface    $categoryRepo,
        private readonly SeoMetaInfoService             $seoMetaInfoService,
        private readonly CategoryService                $categoryService,
        private readonly SeoMetaInfoRepositoryInterface $seoMetaInfoRepo,
        private readonly TranslationRepositoryInterface $translationRepo,
    )
    {
    }

    /**
     * @param Request|null $request
     * @param string|null $type
     * @return View Index function is the starting point of a controller
     * Index function is the starting point of a controller
     */
    public function index(Request|null $request, ?string $type = null): View
    {
        $categories = $this->categoryRepo->getListWhere(
            orderBy: ['updated_at' => 'desc'],
            searchValue: $request->get('searchValue'),
            filters: ['position' => 2],
            relations: ['parent' => function ($query) {
                return $query->with(['parent']);
            }],
            dataLimit: getWebConfig(name: 'pagination_limit'));

        $categoriesWithTrans = $this->categoryRepo->getListWhere(
            orderBy: ['updated_at' => 'desc'],
            searchValue: $request->get('searchValue'),
            filters: ['position' => 2],
            relations: ['translations', 'seo', 'parent'],
            dataLimit: getWebConfig(name: 'pagination_limit'));

        $parentCategories = $this->categoryRepo->getListWhere(
            filters: ['position' => 0],
            dataLimit: 'all');

        $languages = getWebConfig(name: 'pnc_language') ?? null;
        $defaultLanguage = $languages[0];

        return view('admin-views.category.sub-sub-category-view', [
            'categories' => $categories,
            'categoriesWithTrans' => $categoriesWithTrans,
            'parentCategories' => $parentCategories,
            'languages' => $languages,
            'defaultLanguage' => $defaultLanguage,
        ]);
    }

    public function add(SubCategoryAddRequest $request, CategoryService $categoryService): RedirectResponse
    {
        $dataArray = $categoryService->getAddData(request: $request);
        $savedCategory = $this->categoryRepo->add(data: $dataArray);
        $this->translationRepo->add(request: $request, model: 'App\Models\Category', id: $savedCategory->id);
        $seoMetaData = $this->seoMetaInfoService->getModelSEOData(request: $request, seoMetaInfo: $savedCategory?->seo, type: 'App\Models\Category', modelId: $savedCategory->id, action: 'add');
        $this->seoMetaInfoRepo->add(data: $seoMetaData);
        ToastMagic::success(translate('Sub_Sub_Category_Added_Successfully'));
        return back();
    }

    public function update(CategoryUpdateRequest $request, CategoryService $categoryService): JsonResponse
    {
        $dataArray = $categoryService->getUpdateData(request: $request, data: (object)[]);
        $this->categoryRepo->update(id: $request['id'], data: $dataArray);
        $this->translationRepo->update(request: $request, model: 'App\Models\Category', id: $request['id']);

        ToastMagic::success(translate('Sub_Sub_Category_Updated_Successfully'));
        return response()->json();
    }

    public function delete(Request $request): JsonResponse
    {
        $this->categoryRepo->delete(params: ['id' => $request['id']]);
        return response()->json(['message' => translate('deleted_successfully')]);
    }

    public function getSubCategory(Request $request, CategoryService $categoryService): JsonResponse
    {
        $data = $this->categoryRepo->getListWhere(filters: ["parent_id" => $request['id']]);
        return response()->json([
            'html' => $categoryService->getSelectOptionHtml(data: $data),
        ]);
    }

    public function getExportList(Request $request): BinaryFileResponse
    {
        $subSubCategories = $this->categoryRepo->getListWhere(orderBy: ['id' => 'desc'], searchValue: $request->get('searchValue'), filters: ['position' => 2], dataLimit: 'all');
        $active = $subSubCategories->where('home_status', 1)->count();
        $inactive = $subSubCategories->where('home_status', 0)->count();
        return Excel::download(new CategoryListExport([
            'categories' => $subSubCategories,
            'title' => 'sub_sub_category',
            'search' => $request['searchValue'],
            'active' => $active,
            'inactive' => $inactive,
        ]), 'sub-sub-category-list.xlsx'
        );
    }

    public function getImportView(): View
    {
        return view('admin-views.category.bulk-import', [
            'position' => 2,
            'pageTitle' => translate('sub_Sub_Category_Bulk_Import'),
            'formAction' => route('admin.sub-sub-category.import.store'),
            'templateAction' => route('admin.sub-sub-category.import-template'),
            'backRoute' => route('admin.sub-sub-category.view'),
            'importErrors' => session('category_import_errors', []),
        ]);
    }

    public function downloadImportTemplate(): StreamedResponse
    {
        return (new FastExcel(collect($this->categoryService->getImportTemplateSample(2))))
            ->download('sub-sub-category-import-template.xlsx');
    }

    public function import(Request $request): RedirectResponse
    {
        $request->validate(['categories_file' => 'required']);

        $result = $this->categoryService->getImportBulkCategoryData(request: $request, position: 2);
        if (!$result['status']) {
            ToastMagic::error($result['message']);
            return back();
        }

        foreach ($result['rows'] as $row) {
            $this->categoryRepo->add(data: $row);
        }

        if (count($result['errors'])) {
            session()->flash('category_import_errors', $result['errors']);
        }

        ToastMagic::success(count($result['rows']) . ' ' . translate('categories_imported_successfully'));
        return redirect()->route('admin.sub-sub-category.import');
    }

}
