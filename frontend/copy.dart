import 'dart:io';

void main() {
  print('Starting copy process...');
  var dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  var src = File(
    'C:\\Users\\dwive\\.gemini\\antigravity\\brain\\4e2ce5a8-932f-4ae5-8c24-6418fc48c8c6\\media__1772210754064.png',
  );
  if (!src.existsSync()) {
    print('Source file not found at: \${src.path}');
    return;
  }
  src.copySync('assets/icon/app_icon.png');
  print('Copy successful!');
}
