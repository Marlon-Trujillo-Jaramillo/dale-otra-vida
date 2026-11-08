import 'dart:js_interop';

@JS('history.back')
external void _historyBack();

/// The browser's back, as if the member pressed it.
void browserBack() => _historyBack();
