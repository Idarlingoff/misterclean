import 'dart:async';

import 'package:app/shared/styles/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ! 1.2.3 Separation of Concerns
// ? Le package http est importé directement dans la couche présentation. La vue ne devrait pas faire d'appels réseau directs
import 'package:http/http.dart' as http;

import '../../domain/entities/cat.dart';
import '../controllers/cat_notifier.dart';
import '../widgets/cat_item_widget.dart';

class CatListPage extends ConsumerStatefulWidget {
  const CatListPage({super.key});

  @override
  ConsumerState<CatListPage> createState() => _CatListPageState();
}

class _CatListPageState extends ConsumerState<CatListPage> {
  final TextEditingController _editingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showSearch = true;

  Future<String> _fetchCatImage(String id) async {
    final response = await http.get(
        Uri.parse('https://api.thecatapi.com/v1/images/search?breed_ids=$id'));
    return response.body;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    //! 2.1.5. Dead code
    //? Code légèrement inutile
    //! 1.2.10. Hollywood Principal
    //? A pour but de remplacer ce que fait déjà le contrôler
    Timer.periodic(const Duration(seconds: 120), (timer) {
      ref.read(catNotifierProvider.notifier).fetchCats();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  void _onScroll() {
    //! 3.1.4 Naming conventions
    //? Les variables cs, d et mx ont des noms non descriptifs. Elles devraient s'appeler catState, scrollOffset et maxExtent pour plus de lisibilité.
    final cs = ref.read(catNotifierProvider);
    final d = _scrollController.offset;
    final mx = _scrollController.position.maxScrollExtent;
    if (!cs.noMoreCats && !cs.isLoading && d >= mx) {
      ref.read(catNotifierProvider.notifier).fetchCats();
    }
  }

  //! 1.2.8 Law of Demeter
  //? Cette méthode accepte 8 paramètres
  Widget _buildCustomItem(Cat cat, bool isFirst, bool isLast, Color bg,
      double h, String label, bool showIcon, int maxLines) {
    return Container(
      height: h,
      color: bg,
      padding: EdgeInsets.only(top: isFirst ? 10 : 0, bottom: isLast ? 10 : 0),
      child: Row(
        children: [
          if (showIcon) const Icon(Icons.pets),
          const SizedBox(width: 10),
          Expanded(child: Text(label, maxLines: maxLines)),
        ],
      ),
    );
  }

  // ! Bloaters
  // ? Méthode bien trop longue donc dangereuse à retoucher
  // ! Composition de widget
  // ? Préférence à composer plusieurs widget plutôt que d'en faire un gros
  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(catNotifierProvider);

    ref.listen<CatListState>(catNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
      if (next.noMoreCats && previous?.noMoreCats != true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No more cats !")));
      }
    });

    if (catState.isLoading && catState.displayedCats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (catState.error != null && catState.displayedCats.isEmpty) {
      return _errorWidget(catState);
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(UI.s),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.pets, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: UI.s),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cat Browser',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Browse all breeds',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _showSearch
                    ? Container(
                        color: UI.backgroundColor,
                        padding: const EdgeInsets.fromLTRB(
                            UI.pad, UI.pad, UI.pad, UI.pad / 2),
                        child: TextField(
                          onChanged: (value) {
                            ref
                                .read(catNotifierProvider.notifier)
                                .filterCats(value);
                          },
                          controller: _editingController,
                          decoration: const InputDecoration(
                              labelText: "Search",
                              hintText: "Type the name of a cat",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(UI.cornerRadius)))),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                icon: Icon(_showSearch ? Icons.search_off : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.fromLTRB(UI.pad, UI.pad / 2, UI.pad, UI.pad),
              controller: _scrollController,
              itemCount: catState.displayedCats.length + 1,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: UI.pad),
              itemBuilder: (context, index) {
                if (index == catState.displayedCats.length) {
                  if (catState.noMoreCats) {
                    return const SizedBox.shrink();
                  }
                  if (catState.isLoading) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          top: UI.pad - UI.separatorPadding, bottom: UI.pad),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator()),
                          const SizedBox(width: 20),
                          Text(catState.loadingMessage ?? 'Loading...'),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          top: UI.pad - UI.separatorPadding, bottom: UI.pad),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_arrow_down),
                          SizedBox(width: 10),
                          Text("Load more cats ..."),
                          SizedBox(width: 10),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    );
                  }
                } else if (index == 0) {
                  return _buildCustomItem(
                      catState.displayedCats[index],
                      true,
                      false,
                      Colors.teal.shade50,
                      80,
                      catState.displayedCats[index].name,
                      true,
                      1);
                } else {
                  //! 1.2.3. Separation of concerns
                  //? Pas l'endroit idéal pour appeler cette méthode
                  _fetchCatImage(catState.displayedCats[index].id);
                  return CatItem(catState.displayedCats[index]);
                }
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _errorWidget(CatListState catState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () {
            ref.read(catNotifierProvider.notifier).fetchCats();
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh"),
        ),
        const SizedBox(height: 20),
        Text(catState.error!, textAlign: TextAlign.center),
      ],
    );
  }
}
