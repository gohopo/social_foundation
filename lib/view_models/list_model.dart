import 'package:social_foundation/widgets/view_state.dart';

abstract class SfEasyRefreshListModel<T> extends SfRefreshListViewState<T>{
  String? _nextToken;

  Future loadDataOverride(String? nextToken);

  @override
  Future<List<T>> loadData(bool refresh) async {
    var result = await loadDataOverride(refresh?null:_nextToken);
    _nextToken = result['nextToken'];
    return result['rows'];
  }
  @override
  bool loadNoData(int length) => _nextToken==null;
}

class SfSimpleRefreshListModel<T> extends SfEasyRefreshListModel<T>{
  SfSimpleRefreshListModel(this.dataLoader);
  Future Function(String? nextToken) dataLoader;

  @override
  Future loadDataOverride(String? nextToken) => dataLoader.call(nextToken);
}