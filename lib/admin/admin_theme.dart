import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../customer/theme/app_theme.dart';

const adminInk = Color(0xFF0F2744);
const adminMuted = Color(0xFF475569);
const adminPageBg = Color(0xFFF8FAFC);
const adminBorder = Color(0xFFD7DEE8);

const adminHeaderGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    navyDeep,
    navy,
    Color(0xFF123A73),
    Color(0xFF1E5A9C),
    gold,
    goldLight,
  ],
  stops: [0, 0.28, 0.5, 0.72, 0.9, 1],
);

ThemeData get adminWebTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: adminPageBg,
  fontFamily: 'Georgia',
  colorScheme: const ColorScheme.light(
    primary: navy,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: navy,
    surface: Colors.white,
    onSurface: adminInk,
    outline: adminBorder,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: adminInk),
    bodyMedium: TextStyle(color: adminInk),
    bodySmall: TextStyle(color: adminMuted),
    titleLarge: TextStyle(color: adminInk, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(color: adminInk, fontWeight: FontWeight.w700),
    labelLarge: TextStyle(color: adminInk, fontWeight: FontWeight.w700),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  canvasColor: Colors.white,
  cardTheme: const CardThemeData(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: navy),
  dividerColor: adminBorder,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF4F7FB),
    labelStyle: const TextStyle(color: adminMuted, fontWeight: FontWeight.w600),
    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    prefixIconColor: navy,
    suffixIconColor: navy,
    floatingLabelStyle: const TextStyle(
      color: navy,
      fontWeight: FontWeight.w700,
    ),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: navy, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF1F5F9),
    selectedColor: navy,
    disabledColor: const Color(0xFFE2E8F0),
    labelStyle: const TextStyle(color: navy, fontWeight: FontWeight.w700),
    secondaryLabelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    side: const BorderSide(color: adminBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    showCheckmark: false,
  ),
  dropdownMenuTheme: const DropdownMenuThemeData(
    textStyle: TextStyle(color: adminInk, fontWeight: FontWeight.w700),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.white),
    ),
  ),
  dataTableTheme: const DataTableThemeData(
    headingTextStyle: TextStyle(color: navy, fontWeight: FontWeight.w800),
    dataTextStyle: TextStyle(color: adminInk, fontWeight: FontWeight.w600),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: navy,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: navy,
      side: const BorderSide(color: adminBorder),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);

class AdminGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AdminGradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.showMenu = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showMenu;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: adminHeaderGradient),
      ),
      leading: showMenu
          ? Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'Open menu',
              ),
            )
          : null,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: goldLight.withValues(alpha: 0.55)),
            ),
            child: Image.asset(
              'assets/altaqwa_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.ac_unit, color: goldLight),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFF3C4),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

BoxDecoration adminPageDecoration() => const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7FAFF), Color(0xFFF8FAFC)],
  ),
);
