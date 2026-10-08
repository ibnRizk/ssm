import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../catalog/domain/entities/catalog_category.dart';
import '../../../catalog/presentation/widgets/store_card.dart';
import '../cubit/stores_cubit.dart';
import '../cubit/stores_state.dart';
import '../widgets/restaurant_filter_chips.dart';
import '../widgets/restaurants_header.dart';
import '../widgets/stores_search_field.dart';

/// Stores list, pushed inside the Home tab's branch — the bottom navigation
/// bar and its Scaffold live in [MainScaffold]. Expects a [StoresCubit]
/// above it (provided at the route); a category-scoped cubit lists that
/// category's stores, without the zone-wide search.
class RestaurantsScreen extends StatelessWidget {
  /// The category tapped, for the title. Null for the unscoped list — or
  /// a scoped one reached without it, which falls back to the generic title.
  final CatalogCategory? category;

  const RestaurantsScreen({super.key, this.category});

  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool scoped = context.read<StoresCubit>().categoryId != null;
    final String? title = category?.nameFor(
      Localizations.localeOf(context).languageCode,
    );
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<StoresCubit>().load(),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (ScrollUpdateNotification notification) {
            if (notification.metrics.extentAfter < _loadMoreThreshold) {
              context.read<StoresCubit>().loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            // Pull-to-refresh must work even on a short list.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  AppSpacing.lg.h,
                  AppSpacing.screen.w,
                  AppSpacing.md.h,
                ),
                sliver: SliverList.list(
                  children: <Widget>[
                    BlocSelector<StoresCubit, StoresState, int?>(
                      selector: (StoresState state) =>
                          state is StoresLoaded ? state.totalSize : null,
                      builder: (BuildContext context, int? total) =>
                          RestaurantsHeader(
                            title: title,
                            subtitle: total == null
                                ? null
                                : Strings.restaurantsSubtitle(total),
                            onBack: () => context.pop(),
                          ),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    // Only the zone-wide list can be searched or sorted.
                    if (!scoped) ...<Widget>[
                      StoresSearchField(
                        onSearch: (String query) =>
                            context.read<StoresCubit>().search(query),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      const RestaurantFilterChips(),
                    ],
                    SizedBox(height: AppSpacing.xl.h),
                    Text(
                      Strings.restaurantsSectionTitle,
                      style: AppTextStyles.body(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  AppSpacing.sm.h,
                  AppSpacing.screen.w,
                  AppSpacing.xxl.h,
                ),
                sliver: _StoresList(scoped: scoped),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoresList extends StatelessWidget {
  /// Whether it lists one category's stores, for the empty-list wording.
  final bool scoped;

  const _StoresList({required this.scoped});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocBuilder<StoresCubit, StoresState>(
      builder: (BuildContext context, StoresState state) => switch (state) {
        StoresLoaded(:final stores, :final query) when stores.isEmpty =>
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl.h),
              child: Text(
                switch ((query.isEmpty, scoped)) {
                  (false, _) => Strings.restaurantsNoSearchResults,
                  (true, true) => Strings.categoryStoresEmpty,
                  (true, false) => Strings.homeStoresEmpty,
                },
                style: AppTextStyles.body(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        StoresLoaded(:final stores, :final loadMore) => SliverList.separated(
          // One extra row for the load-more footer.
          itemCount: stores.length + 1,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg.h),
          itemBuilder: (BuildContext context, int i) => i < stores.length
              ? StoreCard(
                  store: stores[i],
                  onTap: () => context.push(
                    AppRoutes.storeDetailsPath(stores[i].id),
                    extra: stores[i],
                  ),
                )
              : LoadMoreFooter(
                  status: loadMore,
                  onRetry: () => context.read<StoresCubit>().loadMore(),
                ),
        ),
        StoresError(:final failure) => SliverToBoxAdapter(
          child: ErrorText(
            message: failure.userMessage,
            onRetry: () => context.read<StoresCubit>().load(),
          ),
        ),
        StoresInitial() || StoresLoading() => SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      },
    );
  }
}
