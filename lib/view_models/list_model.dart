import 'package:social_foundation/widgets/view_state.dart';

class SfSimpleRefreshListModel<T> extends SfRefreshListViewState<T>{
  SfSimpleRefreshListModel(this.dataLoader);
  Future Function(String nextToken) dataLoader;
  String _nextToken;

  Future loadDataOverride(String nextToken) => dataLoader?.call(nextToken);

  @override
  Future<List<T>> loadData(bool refresh) async {
    var result = await loadDataOverride(refresh?null:_nextToken);
    _nextToken = result['nextToken'];
    return result['rows'];
  }
  @override
  bool loadNoData(int length) => _nextToken==null;
}