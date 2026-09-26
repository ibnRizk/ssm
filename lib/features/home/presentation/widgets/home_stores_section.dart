import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/presentation/widgets/store_card.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// A preview of the zone's stores; "view all" opens the full list.
class HomeStoresSection extends StatelessWidget {
  const HomeStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.homeStoresTitle,
                style: AppTextStyles.h2(color: c.textPrimary),
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.restaurants),
              child: Text(
                Strings.homeViewAll,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg.h),
        BlocSelector<HomeCubit, HomeState, List<Store>>(
          selector: (HomeState state) =>
              state is HomeLoaded ? state.stores : const <Store>[],
          builder: (BuildContext context, List<Store> stores) {
            if (stores.isEmpty) {
              return Text(
                Strings.homeStoresEmpty,
                style: AppTextStyles.body(color: c.textSecondary),
                textAlign: TextAlign.center,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < stores.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: AppSpacing.lg.h),
                  StoreCard(
                    store: stores[i],
                    onTap: () => context.push(
                      AppRoutes.storeDetailsPath(stores[i].id),
                      extra: stores[i],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
