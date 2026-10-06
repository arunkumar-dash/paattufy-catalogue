/// Route builders, so screens never hand-assemble URLs (AP §4 information
/// architecture).
class Routes {
  static const library = '/library';
  static const groups = '/groups';
  static const download = '/download';
  static const settings = '/settings';
  static const onboarding = '/onboarding';
  static const nowPlaying = '/now-playing';
  static const search = '/search';
  static const lyrics = '/lyrics';
  static const downloads = '/downloads';
  static const libraryHealth = '/library-health';
  static const about = '/about';

  static String artist(String name) => Uri(path: '/artist', queryParameters: {'name': name}).toString();
  static String album(String title, String artist) =>
      Uri(path: '/album', queryParameters: {'title': title, 'artist': artist}).toString();
  static String folder(String path) => Uri(path: '/folder', queryParameters: {'path': path}).toString();
  static String group(int id) => '/group/$id';
  static String groupEdit({int? id, String? type}) => Uri(
        path: '/group-edit',
        queryParameters: {if (id != null) 'id': '$id', 'type': ?type},
      ).toString();
  static String lyricsPicker(String songId) =>
      Uri(path: '/lyrics-picker', queryParameters: {'song': songId}).toString();
  static String site(String id) => '/download/site/$id';
  static String tagEditor(String songId) => '/tag-editor/$songId';
}
