unit Unit2;

interface
Procedure IsPair_TwoPair_Three_Full_Four(var p,tp,t,fh,f: boolean);
Procedure IsFlush(var fl: boolean);
Procedure IsStreet(var s: boolean);

implementation
Uses Unit1;

Procedure IsPair_TwoPair_Three_Full_Four(var p,tp,t,fh,f: boolean);
var i,j: integer;
    c: integer;
begin
  c:=0;
  for i:=2 to 14 do
  begin
    for j:=1 to 5 do
      if Cards[j] in CardNum[i] then inc(c);

      if (c=2) and (t=true) then fh:=true;
      if (c=2) and (p=true) then tp:=true;
      if (c=3) and (p=true) then fh:=true;
      if c=2 then p:=true;
      if c=3 then t:=true;
      if c=4 then f:=true;
      c:=0;
  end;
end;

Procedure IsFlush(var fl: boolean);
var j,c: integer;
begin
  c:=0;
  for j:=1 to 5 do
    if Cards[j] in tref then inc(c);
  if c=5 then fl:=true;
  c:=0;
  for j:=1 to 5 do
    if Cards[j] in bubn then inc(c);
  if c=5 then fl:=true;
  c:=0;
  for j:=1 to 5 do
    if Cards[j] in piki then inc(c);
  if c=5 then fl:=true;
  c:=0;
  for j:=1 to 5 do
    if Cards[j] in cher then inc(c);
  if c=5 then fl:=true;
end;

Procedure IsStreet(var s: boolean);
var i,j,c: integer;
begin
  for i:=1 to 5 do  // приводим все карты к одной масти
      case Cards[i] of
      2,15,28,41: Cards[i]:=2;
      3,16,29,42: Cards[i]:=3;
      4,17,30,43: Cards[i]:=4;
      5,18,31,44: Cards[i]:=5;
      6,19,32,45: Cards[i]:=6;
      7,20,33,46: Cards[i]:=7;
      8,21,34,47: Cards[i]:=8;
      9,22,35,48: Cards[i]:=9;
      10,23,36,49: Cards[i]:=10;
      11,24,37,50: Cards[i]:=11;
      12,25,38,51: Cards[i]:=12;
      13,26,39,52: Cards[i]:=13;
      14,27,40,53: Cards[i]:=14;
      end;
  for i:=1 to 5 do  // сортировка массива Cards по возрастанию (пузырьком)
    for j:=i to 5 do
      if Cards[j]<Cards[i] then
      begin
        c:=Cards[i];
        Cards[i]:=Cards[j];
        Cards[j]:=c;
      end;
if (Cards[2]-Cards[1]=1) and (Cards[3]-Cards[2]=1) and (Cards[4]-Cards[3]=1)
   and (Cards[5]-Cards[4]=1) then s:=true; // т.к. все карты теперь одной масти и упорядочены,
end;                                       // то они все должны отличаться на 1

end.
