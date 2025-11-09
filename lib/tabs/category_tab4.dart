import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:afghan_bazar/blocs/category_tab4_bloc.dart';
import 'package:afghan_bazar/cards/analysis_card.dart';
import 'package:afghan_bazar/utils/empty.dart';
import 'package:afghan_bazar/utils/loading_cards.dart';
import 'package:provider/provider.dart';

class CategoryTab4 extends StatefulWidget {
  final String category;
  final Locale locale;
  const CategoryTab4({super.key, required this.category, required this.locale});

  @override
  _CategoryTab4State createState() => _CategoryTab4State();
}

class _CategoryTab4State extends State<CategoryTab4> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // if (this.mounted) {
    //   context.read<CategoryTab4Bloc>().data.isNotEmpty
    //       ? print('data already loaded')
    //       : context.read<CategoryTab4Bloc>().getData(mounted, widget.category);
    // }e
    context.read<CategoryTab4Bloc>().getData(
      mounted,
      'World',
      true,
      widget.locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cb = context.watch<CategoryTab4Bloc>();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CategoryTab4Bloc>().onRefresh(mounted, widget.category);
      },
      child: cb.hasData == false
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                EmptyPage(
                  icon: Icons.paste, // Feather.clipboard,
                  message: 'No articles found',
                  message1: '',
                ),
              ],
            )
          : ListView.separated(
              key: PageStorageKey(widget.category),
              padding: EdgeInsets.all(15),
              physics: NeverScrollableScrollPhysics(),
              itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 5,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 15),
              shrinkWrap: true,
              itemBuilder: (_, int index) {
                if (index < cb.data.length) {
                  return AnalysisCard(
                    d: cb.data[index],
                    heroTag: 'heroTag$index',
                  );
                  // if (index % 2 == 0 && index != 0)
                  //   return Card1(d: cb.data[index], heroTag: 'tab3$index');
                  // return Card2(d: cb.data[index], heroTag: 'tab3$index');
                }
                return Opacity(
                  opacity: cb.isLoading ? 1.0 : 0.0,
                  child:
                      true //cb.lastVisible == null
                      ? LoadingCard(height: 250)
                      : Center(
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                );
              },
            ),
    );
  }
}
