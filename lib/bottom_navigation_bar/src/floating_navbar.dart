import 'floating_navbar_item.dart';
import 'package:flutter/material.dart';

typedef Widget ItemBuilder(
    BuildContext context, int index, FloatingNavbarItem items);

class FloatingNavbar extends StatefulWidget {
  final List<FloatingNavbarItem> items;
  final int currentIndex;
  final void Function(int val)? onTap;
  final Color selectedBackgroundColor;
  final AssetImage? selectedBackgroundImg;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color backgroundColor;
  final double fontSize;
  final double iconSize;
  final double itemBorderRadius;
  final double borderRadius;
  final ItemBuilder itemBuilder;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double width;
  final double elevation;

  FloatingNavbar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    ItemBuilder? itemBuilder,
    this.backgroundColor = Colors.white,
    this.selectedBackgroundColor = Colors.white,
    this.selectedBackgroundImg,
    this.selectedItemColor = Colors.black,
    this.iconSize = 24.0,
    this.fontSize = 9.0,
    this.borderRadius = 0,
    this.itemBorderRadius = 8,
    this.unselectedItemColor = Colors.white,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
    this.width = double.infinity,
    this.elevation = 8.0,
  })  : assert(items.length > 1),
        assert(items.length <= 5),
        assert(currentIndex <= items.length),
        assert(width > 50),
        this.itemBuilder = itemBuilder ??
            _defaultItemBuilder(
              unselectedItemColor: unselectedItemColor,
              selectedItemColor: selectedItemColor,
              borderRadius: borderRadius,
              fontSize: fontSize,
              width: width,
              backgroundColor: backgroundColor,
              currentIndex: currentIndex,
              iconSize: iconSize,
              itemBorderRadius: itemBorderRadius,
              items: items,
              onTap: onTap,
              selectedBackgroundColor: selectedBackgroundColor,
              selectedBackgroundImg: selectedBackgroundImg,
            ),
        super(key: key);

  @override
  _FloatingNavbarState createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> {
  List<FloatingNavbarItem> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2A3B53).withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: const Color(0xff2A3B53).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8.0,
              offset: const Offset(1, 0),
            )
          ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: widget.padding,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: widget.backgroundColor,
            ),
            width: widget.width,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: items
                    .asMap()
                    .map((i, f) {
                  return MapEntry(i, widget.itemBuilder(context, i, f));
                })
                    .values
                    .toList(),
              ),
          ),
        ],
      ),
    );
  }
}

ItemBuilder _defaultItemBuilder({
  Function(int val)? onTap,
  required List<FloatingNavbarItem> items,
  int? currentIndex,
  Color? selectedBackgroundColor,
  AssetImage? selectedBackgroundImg,
  Color? selectedItemColor,
  Color? unselectedItemColor,
  Color? backgroundColor,
  double width = double.infinity,
  double? fontSize,
  double? iconSize,
  double? itemBorderRadius,
  double? borderRadius,
}) {
  return (BuildContext context, int index, FloatingNavbarItem item) => Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(4.0, 6.0, 4.0, 6.0),
                margin: EdgeInsets.only(left: item.title == 'Analytics' ? 10 : 0),
                /*duration: const Duration(milliseconds: 300),*/
                decoration: BoxDecoration(
                  /*color: currentIndex == index
                      ? selectedBackgroundColor
                      : Colors.transparent,*/
                  image: currentIndex == index ? DecorationImage(
                      image: selectedBackgroundImg!,
                      fit: BoxFit.contain,
                      scale: 4.0
                  ) : null,
                ),
                child: InkWell(
                  onTap: () {
                    onTap!(index);
                  },
                  /*borderRadius: BorderRadius.circular(8),*/
                  child: Container(
                    /*width: MediaQuery.of(context).size.width / items.length - 2,*/
                    /*constraints: const BoxConstraints(
                      minWidth: 80.0
                  ),*/
                    // margin: EdgeInsets.only(left: item.title == 'Analytics' ? 12 : 0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 2, vertical: item.title != null ? 3 : 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        item.customWidget == null
                            ? Icon(
                          item.icon,
                          color: currentIndex == index
                              ? selectedItemColor
                              : unselectedItemColor,
                          size: iconSize,
                        )
                            : item.customWidget!,
                        if (item.title != null)
                          Text(
                            '${item.title}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: currentIndex == index
                                    ? selectedItemColor
                                    : unselectedItemColor,
                                fontSize: fontSize,
                                fontWeight: currentIndex == index
                                    ? FontWeight.w500
                                    : FontWeight.w300
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      );
}
