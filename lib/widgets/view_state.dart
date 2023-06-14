import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum SfViewStatus {
  idle,
  busy,
  empty,
  error,
  unAuthorized
}

abstract class SfViewState extends ChangeNotifier {
  SfViewStatus _viewStatus;
  bool _disposed = false;
  dynamic _error;

  SfViewState({SfViewStatus viewStatus=SfViewStatus.idle}) : _viewStatus = viewStatus;
  Future initDataVsync(TickerProviderStateMixin vsync) => initData();
  Future initData() async {}
  void onRefactor(SfViewState newState){}
  bool get wantKeepAlive => false;
  SfViewStatus get viewStatus => _viewStatus;
  dynamic get error => _error;
  set viewStatus(SfViewStatus viewStatus){
    _viewStatus = viewStatus;
    notifyListeners();
  }
  bool get isIdle => viewStatus == SfViewStatus.idle;
  bool get isBusy => viewStatus == SfViewStatus.busy;
  bool get isEmpty => viewStatus == SfViewStatus.empty;
  bool get isError => viewStatus == SfViewStatus.error;
  bool get isUnAuthorized => viewStatus == SfViewStatus.unAuthorized;
  bool get isDisposed => _disposed == true;
  void setIdle(){
    viewStatus = SfViewStatus.idle;
  }
  void setBusy(){
    viewStatus = SfViewStatus.busy;
  }
  void setEmpty(){
    viewStatus = SfViewStatus.empty;
  }
  void setError(error){
    viewStatus = SfViewStatus.error;
    _error = error;
  }
  void setUnAuthorized(){
    viewStatus = SfViewStatus.unAuthorized;
  }
  //解决build中调用notifyListeners的错误
  Future delayedNotifyListeners(int milliseconds) => Future.delayed(Duration(milliseconds:milliseconds),() => notifyListeners());

  @override
  void dispose(){
    _disposed = true;
    super.dispose();
  }
  @override
  void notifyListeners(){
    if(!_disposed){
      super.notifyListeners();
    }
  }
}

abstract class SfListViewState<T> extends SfViewState {
  List<T> list = [];

  Future<List<T>> loadData(bool refresh);
  Future refresh() async {
    try{
      var data = await loadData(true);
      if(data.isEmpty){
        list.clear();
        setEmpty();
      }
      else{
        onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    }
    catch(e){
      setError(e);
    }
  }
  void onCompleted(List<T> data){}

  @override
  Future initData() async {
    setBusy();
    await refresh();
  }
}

abstract class SfRefreshListViewState<T> extends SfListViewState<T> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;
  Future<List<T>?> loadMore() async {
    try{
      var data = await loadData(false);
      if(loadNoData(data.length)){
        refreshController.loadNoData();
      }
      else{
        refreshController.loadComplete();
      }
      if(data.isNotEmpty){
        onCompleted(data);
        list.addAll(data);
      }
      notifyListeners();
      return data;
    }
    catch(e){
      refreshController.loadFailed();
      return null;
    }
  }
  bool loadNoData(int length) => length<20;

  @override
  Future refresh() async {
    try{
      var data = await loadData(true);
      refreshController.refreshCompleted();
      if(loadNoData(data.length)){
        refreshController.loadNoData();
      }
      else{
        refreshController.loadComplete();
      }
      if(data.isEmpty){
        list.clear();
        setEmpty();
      }
      else{
        onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    }
    catch(e){
      refreshController.refreshFailed();
      setError(e);
    }
  }
  @override
  void dispose(){
    _refreshController.dispose();
    super.dispose();
  }
}