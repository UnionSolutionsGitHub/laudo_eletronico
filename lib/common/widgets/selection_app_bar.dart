import 'package:flutter/material.dart';
import 'package:laudo_eletronico/infrastructure/resources/dimens.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedItemsCount;
  final Function cancelSelection;
  final Function deleteSelected;

  SelectionAppBar({
    @required this.selectedItemsCount,
    @required this.cancelSelection,
    @required this.deleteSelected,
  });

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: cancelSelection,
      ),
      title: Text("$selectedItemsCount"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: deleteSelected,
        ),
      ],
    );
  }
}
