import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String title;
  final Widget child, extraActions;
  final IconButton extraActionButton;
  final TextEditingController queryController;
  final Function(String) onQueryChanged, onQuerySubmitted;
  final FloatingActionButton floatingActionButton;

  SearchBar({
    @required this.title,
    @required this.queryController,
    @required this.onQueryChanged,
    this.child,
    this.onQuerySubmitted,
    this.extraActions,
    this.floatingActionButton,
    this.extraActionButton,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool _isSearchActive;
  bool _isShowingClearIcon;
  TextEditingController _edtxController;

  @override
  void initState() {
    _isSearchActive = false;
    _isShowingClearIcon = false;
    _edtxController = this.widget?.queryController;
    super.initState();
  }

  Future<bool> _onBackPressed() async {
    setState(() {
      _isSearchActive = !_isSearchActive;
      this.widget.onQueryChanged("");
    });

    _edtxController.text = "";
    return _isSearchActive;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.of(context).canPop()
              ? null
              : _isSearchActive
                  ? IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        _onBackPressed();
                      },
                    )
                  : null,
          title: _isSearchActive
              ? TextField(
                  controller: _edtxController,
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (s) {
                    this.widget.onQuerySubmitted(s);
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          MaterialLocalizations.of(context).searchFieldLabel,
                      hintStyle:
                          TextStyle(color: Colors.white70, fontSize: 22.0)),
                  onChanged: (s) {
                    setState(() {
                      _isShowingClearIcon = s.length > 0;
                      this.widget.onQueryChanged(s);
                    });
                  },
                )
              : Text(
                  this.widget.title,
                ),
          actions: <Widget>[
            !_isSearchActive
                ? IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearchActive = !_isSearchActive;
                      });
                    },
                  )
                : _isShowingClearIcon
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _edtxController.text = "";
                          setState(() {
                            _isShowingClearIcon = false;
                            this.widget.onQueryChanged("");
                          });
                        },
                      )
                    : Container(),
            !_isSearchActive
                ? this.widget?.extraActionButton ?? Container()
                : Container(),
            !_isSearchActive
                ? this.widget?.extraActions ?? Container()
                : Container(),
          ],
        ),
        body: this.widget?.child ?? Container(),
        floatingActionButton: this.widget.floatingActionButton,
      ),
    );
  }
}
