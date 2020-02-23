import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum ViewStatus {
  idle,
  busy,
  empty,
  error,
  unAuthorized
}

abstract class ViewState extends ChangeNotifier {
  ViewStatus _viewStatus;
  bool _disposed = false;

  ViewState({ViewStatus viewStatus : ViewStatus.idle}) : _viewStatus = viewStatus;
  void initData(){}
  ViewStatus get viewStatus => _viewStatus;
  set viewStatus(ViewStatus viewStatus){
    _viewStatus = viewStatus;
    notifyListeners();
  }
  bool get isIdle => viewStatus == ViewStatus.idle;
  bool get isBusy => viewStatus == ViewStatus.busy;
  bool get isEmpty => viewStatus == ViewStatus.empty;
  bool get isError => viewStatus == ViewStatus.error;
  bool get isUnAuthorized => viewStatus == ViewStatus.unAuthorized;
  void setIdle(){
    viewStatus = ViewStatus.idle;
  }
  void setBusy(){
    viewStatus = ViewStatus.busy;
  }
  void setEmpty(){
    viewStatus = ViewStatus.empty;
  }
  void setError(){
    viewStatus = ViewStatus.error;
  }
  void setUnAuthorized(){
    viewStatus = ViewStatus.unAuthorized;
  }

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

abstract class ListViewState<T> extends ViewState {
  List<T> list = [];

  Future<List<T>> loadData(bool refresh);
  Future<void> refresh() async {
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
      setError();
    }
  }
  void onCompleted(List<T> data){}

  @override
  void initData() async {
    setBusy();
    await refresh();
  }
}

abstract class RefreshListViewState<T> extends ListViewState<T> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;
  Future<List<T>> loadMore() async {
    try{
      var data = await loadData(false);
      if(data.isEmpty){
        refreshController.loadNoData();
      }
      else{
        onCompleted(data);
        list.addAll(data);
        if(loadNoData(data.length)){
          refreshController.loadNoData();
        }
        else{
          refreshController.loadComplete();
        }
        notifyListeners();
      }
      return data;
    }
    catch(e){
      refreshController.loadFailed();
      return null;
    }
  }
  bool loadNoData(int length) => length<20;

  @override
  Future<void> refresh() async {
    try{
      var data = await loadData(true);
      if(data.isEmpty){
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      }
      else{
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        if(loadNoData(data.length)){
          refreshController.loadNoData();
        }
        else{
          refreshController.loadComplete();
        }
        setIdle();
      }
    }
    catch(e){
      refreshController.refreshFailed();
      setError();
    }
  }
  @override
  void dispose(){
    _refreshController.dispose();
    super.dispose();
  }
}