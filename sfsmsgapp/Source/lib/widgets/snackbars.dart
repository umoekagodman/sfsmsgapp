import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Error SnackBar
SnackBar snackBarError(String message) {
  return SnackBar(
    content: StackContent(
      message: message,
      type: SnackBarType.error,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

// Success SnackBar
SnackBar snackBarSuccess(String message) {
  return SnackBar(
    content: StackContent(
      message: message,
      type: SnackBarType.success,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

// Warning SnackBar
SnackBar snackBarWarning(String message) {
  return SnackBar(
    content: StackContent(
      message: message,
      type: SnackBarType.warning,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

// Info SnackBar
SnackBar snackBarInfo(String message) {
  return SnackBar(
    content: StackContent(
      message: message,
      type: SnackBarType.info,
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

// SnackBar Types
enum SnackBarType { error, warning, info, success }

// StackContent
class StackContent extends StatelessWidget {
  final String message;
  final SnackBarType type;

  const StackContent({
    required this.message,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color iconColor;
    String icon;
    switch (type) {
      case SnackBarType.error:
        color = const Color(0xFFc72c41);
        iconColor = const Color(0XFF801436);
        icon = 'assets/images/snackbars/types/error.svg';
        break;
      case SnackBarType.warning:
        color = const Color(0xFFef8d32);
        iconColor = const Color(0XFFcc561e);
        icon = 'assets/images/snackbars/types/warning.svg';
        break;
      case SnackBarType.info:
        color = const Color(0xFF0070e0);
        iconColor = const Color(0XFF07478a);
        icon = 'assets/images/snackbars/types/info.svg';
        break;
      case SnackBarType.success:
        color = const Color(0xFF0d7040);
        iconColor = const Color(0XFF004e32);
        icon = 'assets/images/snackbars/types/success.svg';
        break;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 48,
              ),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/images/snackbars/bubbles.svg',
              width: 40,
              height: 48,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
        ),
        Positioned(
          top: -12,
          left: 12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/images/snackbars/back.svg',
                width: 40,
                height: 40,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                //color: iconColor,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
