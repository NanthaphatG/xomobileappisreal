class History{
  String PlayerW='';
  String Matrix='';
  String Datetime='';

  History(String PlayerW,String Matrix,String Datetime){
    this.PlayerW = PlayerW;
    this.Matrix = Matrix;
    this.Datetime = Datetime;
  }
  History.empty(){
    this.PlayerW='';
    this.Matrix='';
    this.Datetime='';
  }
}

class GameHistory{
  String hisGam='';
  GameHistory(int no,String hisGame){
    this.hisGam=hisGam;
  }
  GameHistory.empty(){
    this.hisGam='';
  }
}