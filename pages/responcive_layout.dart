import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shopp_app/pages/global_variable.dart';
import 'package:shopp_app/providers/user_provider.dart';

class responsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobScreenLayout;

  const responsiveLayout(
      {Key? key, required this.webScreenLayout, required this.mobScreenLayout})
      : super(key: key);

  @override
  State<responsiveLayout> createState() => _responsiveLayoutState();
}

class _responsiveLayoutState extends State<responsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return widget.webScreenLayout;
      }
      return widget.mobScreenLayout;
    });
  }
}
