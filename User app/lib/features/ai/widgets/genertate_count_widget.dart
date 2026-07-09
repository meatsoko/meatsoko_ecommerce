import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class GeneratesLeftCount extends StatelessWidget {
  const GeneratesLeftCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.of<SplashController>(Get.context!,listen: false).configModel?.isAiFeatureEnabled == true ?  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwelve),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15)
          ),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),

          child: Consumer<AuctionAiController>(
            builder: (context, aiController, child){
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text('${aiController.genLimit}',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeEight),
                    child: Text(getTranslated('generates_left', context) ?? '',
                      style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),

                  Icon(Icons.auto_awesome, color: Colors.blue, size: 16),

                ],
              );
            }
          ),
        )
      ],
    ) : SizedBox();
  }
}
