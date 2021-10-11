unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, Unit2, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    SpeedButton1: TSpeedButton;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TSet = set of 1..52;

var
  Form1: TForm1;
  mark: set of 0..52;
  Bmp: TBitmap;
  h: THandle;
  bank: integer = 100; // начальная ставка
  stavka: integer;
  cards: array [1..5] of integer; // номера ресурсов каждой карты в cards.dll
  hold: array [1..5] of boolean; // оставлять карту или нет
  open: boolean = false; // если карты открыты(можно двигать или нет)
  again: boolean = false; // закрыть все карты после конца партии

  tref,bubn,piki,cher: TSet; // номера ресурсов для каждой масти
                             // заполняются при старте (FormCreate)

  CardNum: array [2..14] of TSet; // номера ресурсов для всех двоек, троек, ..., тузов
                                  // заполняется при старте
  Pair: boolean = false;
  TwoPair: boolean = false;
  Three: boolean = false;
  FullHouse: boolean = false;
  Four: boolean = false;
  Flush: boolean = false;
  Street: boolean = false;

implementation

{$R *.DFM}

Procedure SetClose(count: integer); // все карты обложкой вверх если count=0
var i: integer;
begin
  Bmp.Handle := LoadBitmap(h,'#59');
  if count=0 then
  for i:=1 to 5 do
    with Form1 do
    begin
      (FindComponent('Image' + IntToStr(i)) as TImage).Canvas.Draw(0, 0, Bmp);
      hold[i]:=false; // не оставлять карты
    end
  else
    with Form1 do
    begin
      (FindComponent('Image' + IntToStr(count)) as TImage).Canvas.Draw(0, 0, Bmp);
      hold[count]:=false; // не оставлять закрытую карту
    end;
  Form1.Refresh;
end;

Procedure ClearImages(count: integer);
var i: integer;
begin
  with Form1 do
  if count<>0 then
  PatBlt((FindComponent('Image' + IntToStr(count)) as TImage).Canvas.Handle,0,0,71,116,WHITENESS)
  else
  for i:=1 to 5 do
    PatBlt((FindComponent('Image' + IntToStr(i)) as TImage).Canvas.Handle,0,0,71,116,WHITENESS);
end;

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
    path: array[0..255] of char;
begin
  Bmp := TBitmap.Create;
  GetWindowsDirectory(path,sizeOf(path));
  h := LoadLibrary(PChar(path+'\system32\cards.dll'));
  SetClose(0); // закрываем все карты
  Randomize;

  for i:=2 to 13 do // заполняем для карт 2 - король
    CardNum[i]:=[i,i+13,i+26,i+39];
  CardNum[14]:=[1,14,27,40]; // тузы

  tref:=[1..13];
  bubn:=[14..26];
  piki:=[40..52];
  cher:=[27..39];
end;

function getNumber(i: integer): integer; // получение уникального числа, номера ресурса в Cards.dll
var c: integer;
    label label1;
begin
  label1:
  c:=Random(53);
  if c=0 then c:=1;
  if (c in mark) then goto label1 else Include(mark,c);
  cards[i]:=c;
  Result:=c;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var i: integer;
begin
  if again then // партия закончена, ждем новую
  begin
    SetClose(0);
    SpinEdit1.Enabled:=true; // ставку менять можно
    SpeedButton1.Caption:='Раздать';
    Label1.Caption:='';
    again:=false;
    exit;
  end;
  if not open then // карты вообще не открыты
  begin
    SpinEdit1.Enabled:=false; // ставку менять нельзя
    stavka:=SpinEdit1.Value; // считываем ставку
    Label3.Caption:='Банк: '+IntToStr(bank-stavka)+'$';
    ClearImages(0);
    SetClose(0);
    mark:=[];
    for i:=1 to 5 do // раздаем карты
    begin
      Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(getNumber(i))));
      (FindComponent('Image' + IntToStr(i)) as TImage).Canvas.Draw(0, 0, Bmp);
      (FindComponent('Image' + IntToStr(i)) as TImage).Refresh;
      Sleep(300);
      open:=true; // карты открыты
    end;
  end
  else  // досдаем карты
  begin
    mark:=[];
    for i:=1 to 5 do
    if not hold[i] then  // если карту не оставлять, то ее надо закрыть
    begin
      ClearImages(i);
      SetClose(i);
    end
    else
    begin
      Include(mark,cards[i]); // оставленные карты поднять на прежний уровень
      ClearImages(i);
      Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[i])));
      (FindComponent('Image' + IntToStr(i)) as TImage).Canvas.Draw(0, 0, Bmp);
    end;
    Form1.Refresh;
    for i:=1 to 5 do // докинуть карты, которые нужно менять
    begin
      if not hold[i] then
      begin
        Sleep(300);
        Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(getNumber(i))));
        (FindComponent('Image' + IntToStr(i)) as TImage).Canvas.Draw(0, 0, Bmp);
        (FindComponent('Image' + IntToStr(i)) as TImage).Refresh;
      end;
    end;
    open:=false; // карты открыты
    again:= true;
    SpeedButton1.Caption:='Снова';

    Pair:= false; 
    TwoPair:= false;
    Three:= false;
    FullHouse:= false;
    Four:= false;
    Flush:= false;
    Street:= false;  
                      // проверки на комбинации - в Unit2
    IsPair_TwoPair_Three_Full_Four(Pair,TwoPair,Three,FullHouse,Four);
    IsFlush(Flush);
    IsStreet(Street);

    if Street and Flush then Label1.Caption:='Street Flush' else
    if Four then Label1.Caption:='Four of kind' else
    if FullHouse then Label1.Caption:='Full House' else
    if Flush then Label1.Caption:='Flush' else
    if Street then Label1.Caption:='Street' else
    if Three then Label1.Caption:='Three of kind' else
    if TwoPair then Label1.Caption:='Two Pair' else
    if Pair then Label1.Caption:='Pair' else Label1.Caption:='Bad Luck';

    if Street and Flush then bank:=bank+49*stavka else // подсчитываем банк
    if Four then bank:=bank+29*stavka else             // сразу откладываем ставку на сл. игру
    if FullHouse then bank:=bank+19*stavka else
    if Flush then bank:=bank+14*stavka else
    if Street then bank:=bank+9*stavka else
    if Three then bank:=bank+5*stavka else
    if TwoPair then bank:=bank+3*stavka else
    if Pair then bank:=bank+stavka else bank:=bank-stavka;

    if bank<=0 then // если все проиграли
    begin
      MessageBox(handle,'You busted!','',mb_OK+mb_IconAsterisk+mb_TaskModal);
      SpinEdit1.Value:=1;
      stavka:=1;
      bank:=100;
    end;

    if bank-stavka<0 then // если старая ставка больше банка
    begin
      SpinEdit1.Value:=bank;
      stavka:=bank;
    end;

    Label3.Caption:='Банк: '+IntToStr(bank-stavka)+'$';
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Bmp.Free;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  if not open then exit; // если карты закрыты, то ничего двигать нельзя, выход
  PatBlt(Image1.Canvas.Handle,0,0,Image1.Width,Image1.Height,WHITENESS);
  Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[1])));
  if not hold[1] then // карту или поднять при повторном щелчке, или опустить вниз
  Image1.Canvas.Draw(0, 20, Bmp)
  else
  Image1.Canvas.Draw(0, 0, Bmp);
  hold[1]:= not hold[1]; // изменить состояние карты
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  if not open then exit;
  PatBlt(Image2.Canvas.Handle,0,0,Image2.Width,Image2.Height,WHITENESS);
  Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[2])));
  if not hold[2] then
  Image2.Canvas.Draw(0, 20, Bmp)
  else
  Image2.Canvas.Draw(0, 0, Bmp);
  hold[2]:= not hold[2];
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  if not open then exit;
  PatBlt(Image3.Canvas.Handle,0,0,Image3.Width,Image3.Height,WHITENESS);
  Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[3])));
  if not hold[3] then
  Image3.Canvas.Draw(0, 20, Bmp)
  else
  Image3.Canvas.Draw(0, 0, Bmp);
  hold[3]:= not hold[3];
end;

procedure TForm1.Image4Click(Sender: TObject);
begin
  if not open then exit;
  PatBlt(Image4.Canvas.Handle,0,0,Image4.Width,Image4.Height,WHITENESS);
  Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[4])));
  if not hold[4] then
  Image4.Canvas.Draw(0, 20, Bmp)
  else
  Image4.Canvas.Draw(0, 0, Bmp);
  hold[4]:= not hold[4];
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
  if not open then exit;
  PatBlt(Image5.Canvas.Handle,0,0,Image5.Width,Image5.Height,WHITENESS);
  Bmp.Handle := LoadBitmap(h,PChar('#'+IntToStr(cards[5])));
  if not hold[5] then
  Image5.Canvas.Draw(0, 20, Bmp)
  else
  Image5.Canvas.Draw(0, 0, Bmp);
  hold[5]:= not hold[5];
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
stavka:=SpinEdit1.Value; // считываем ставку
if bank-stavka<0 then
begin
  stavka:=bank;
  SpinEdit1.Value:=stavka;
end;
Label3.Caption:='Банк: '+IntToStr(bank-stavka)+'$';
end;

end.
