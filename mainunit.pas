unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, Menus, DCPU16, LazHelp, SynEdit,
  SynHighlighterAny, GraphType, LCLIntf, LCLType, types;

const
  VideoStart = $8000;
  KeyboardAddress = $9000;

type

  TFontChar = bitpacked array [0..3, 0..7] of Boolean;
  TSmallFont = array [0..127] of TFontChar;

  { TMain }

  TMain = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    btReset: TButton;
    btAssemble: TButton;
    btSingleStep: TButton;
    cbRunning: TCheckBox;
    cbFollow: TCheckBox;
    cbCycleExact: TCheckBox;
    ilIcons: TImageList;
    lbScreen: TLabel;
    LazHelp1: TLazHelp;
    LazHelpWindowedViewer1: TLazHelpWindowedViewer;
    lbLastCycles: TLabel;
    lbNextInstructionState: TLabel;
    lbMemoryDumpLabel: TLabel;
    lbDisassemblyLabel: TLabel;
    lbCPUState: TLabel;
    lbMessages: TLabel;
    lbPC: TLabel;
    lbSP: TLabel;
    lbO: TLabel;
    lbAssembly: TLabel;
    lbJ: TLabel;
    lbRegisters: TLabel;
    lbA: TLabel;
    lbB: TLabel;
    lbC: TLabel;
    lbX: TLabel;
    lbY: TLabel;
    lbZ: TLabel;
    lbI: TLabel;
    lbDisassembly: TListBox;
    lbMemoryDump: TListBox;
    MainMenu1: TMainMenu;
    mCPUBar1: TMenuItem;
    mCPUSaveProgram: TMenuItem;
    mCPULoadProgram: TMenuItem;
    mCPUBar2: TMenuItem;
    mCPUUseBigEndianWords: TMenuItem;
    mAssemblyRemoveBreakpoints: TMenuItem;
    mCPUFullReset: TMenuItem;
    mViewClearMessages: TMenuItem;
    mViewBar1: TMenuItem;
    mViewUserScreen: TMenuItem;
    mView: TMenuItem;
    mFileNew: TMenuItem;
    mFileOpen: TMenuItem;
    mFileSave: TMenuItem;
    mFileSaveAs: TMenuItem;
    MenuItem5: TMenuItem;
    mFileQuit: TMenuItem;
    mCPU: TMenuItem;
    mCPUReset: TMenuItem;
    mCPUSingleStep: TMenuItem;
    mAssembly: TMenuItem;
    mAssemblyAssemble: TMenuItem;
    mHelpBar1: TMenuItem;
    mHelpContents: TMenuItem;
    mHelpAbout: TMenuItem;
    mHelp: TMenuItem;
    mFile: TMenuItem;
    mMessages: TMemo;
    odCode: TOpenDialog;
    odProgram: TOpenDialog;
    pbScreen: TPaintBox;
    plScreen: TPanel;
    sdProgram: TSaveDialog;
    sdCode: TSaveDialog;
    seA: TSpinEdit;
    seJ: TSpinEdit;
    seO: TSpinEdit;
    seB: TSpinEdit;
    seC: TSpinEdit;
    seX: TSpinEdit;
    seY: TSpinEdit;
    seZ: TSpinEdit;
    seI: TSpinEdit;
    sePC: TSpinEdit;
    seSP: TSpinEdit;
    mCode: TSynEdit;
    sasAssembly: TSynAnySyn;
    StringListLazHelpProvider1: TStringListLazHelpProvider;
    procedure ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
    procedure btAssembleClick(Sender: TObject);
    procedure btResetClick(Sender: TObject);
    procedure btSingleStepClick(Sender: TObject);
    procedure cbCycleExactChange(Sender: TObject);
    procedure cbRunningChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbDisassemblyDblClick(Sender: TObject);
    procedure lbDisassemblyDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure lbMemoryDumpDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure mAssemblyAssembleClick(Sender: TObject);
    procedure mAssemblyRemoveBreakpointsClick(Sender: TObject);
    procedure mCPUFullResetClick(Sender: TObject);
    procedure mCPULoadProgramClick(Sender: TObject);
    procedure mCPUResetClick(Sender: TObject);
    procedure mCPUSaveProgramClick(Sender: TObject);
    procedure mCPUSingleStepClick(Sender: TObject);
    procedure mCPUUseBigEndianWordsClick(Sender: TObject);
    procedure mFileNewClick(Sender: TObject);
    procedure mFileOpenClick(Sender: TObject);
    procedure mFileQuitClick(Sender: TObject);
    procedure mFileSaveAsClick(Sender: TObject);
    procedure mFileSaveClick(Sender: TObject);
    procedure mHelpAboutClick(Sender: TObject);
    procedure mHelpContentsClick(Sender: TObject);
    procedure mViewClearMessagesClick(Sender: TObject);
    procedure mViewUserScreenClick(Sender: TObject);
    procedure pbScreenPaint(Sender: TObject);
    procedure seAChange(Sender: TObject);
    procedure seBChange(Sender: TObject);
    procedure seCChange(Sender: TObject);
    procedure seIChange(Sender: TObject);
    procedure seJChange(Sender: TObject);
    procedure seOChange(Sender: TObject);
    procedure sePCChange(Sender: TObject);
    procedure seSPChange(Sender: TObject);
    procedure seXChange(Sender: TObject);
    procedure seYChange(Sender: TObject);
    procedure seZChange(Sender: TObject);
  private
    FCPU: TCPU;
    FFileName: string;
    Fnt: TSmallFont;
    PrevRegValues: array [TCPURegister] of Word;
    SpinEditByReg: array [TCPURegister] of TSpinEdit;
    InstructionAddresses: array [TMemoryAddress] of Integer;
    DisassembledLines: array [TMemoryAddress] of string;
    Breakpoint, ExecutedMark: array [TMemoryAddress] of Boolean;
    LastKnownProgramSize: Integer;
    ScreenBitmap: TBitmap;
    NowTicks, LastTicks: Cardinal;
    CycleExact: Boolean;
    Running: Boolean;
    IgnoreFollow: Boolean;
    procedure OnMemoryChange(ASender: TObject; MemoryAddress: TMemoryAddress; var MemoryValue: Word);
    procedure OnRegisterChange(ASender: TObject; CPURegister: TCPURegister; var RegisterValue: Word);
    procedure DisassembleFrom(Address, EndAddress: TMemoryAddress);
    procedure SetFileName(const AValue: string);
    procedure SingleStep;
    procedure Reset;
    procedure DrawScreen;
    function ConfirmOk: Boolean;
    procedure UpdateAllMonitors;
  public
    procedure KeyWasTyped(Ch: Char);
    property CPU: TCPU read FCPU;
    property FileName: string read FFileName write SetFileName;
  end; 

var
  Main: TMain;

procedure WriteMessage(AMsg: string);

implementation

uses
  UserScreenUnit;

procedure WriteMessage(AMsg: string);
begin
  if Assigned(Main) then begin
    Main.mMessages.Lines.Add(AMsg);
    Application.ProcessMessages;
  end;
end;

{$R *.lfm}

{ TMain }

procedure TMain.FormCreate(Sender: TObject);
var
  I: Integer;
  S: string;

  procedure LoadFont;
  var
    {$IFDEF WINDOWS}
    Stream: TResourceStream;
    {$ELSE}
    Stream: TFileStream;
    {$ENDIF}
  begin
    Stream:=nil;
    try
      {$IFDEF WINDOWS}
      Stream:=TResourceStream.Create(HINSTANCE, 'FONTDATA', 'FONTDATA');
      {$ELSE}
      Stream:=TFileStream.Create('fontdata.fda', fmOpenRead);
      {$ENDIF}
      Stream.Read(Fnt, SizeOf(Fnt));
    except
      MessageDlg('Error', 'Error loading fonts', mtError, [mbOK], 0);
    end;
    FreeAndNil(Stream);
  end;

begin
  LoadFont;
  lbDisassembly.ScrollWidth:=0;
  lbMemoryDump.ScrollWidth:=0;
  ScreenBitmap:=TBitmap.Create;
  ScreenBitmap.PixelFormat:=pf32bit;
  ScreenBitmap.SetSize(128, 128);
  WriteMessage('Welcome');
  SpinEditByReg[crA]:=seA;
  SpinEditByReg[crB]:=seB;
  SpinEditByReg[crC]:=seC;
  SpinEditByReg[crX]:=seX;
  SpinEditByReg[crY]:=seY;
  SpinEditByReg[crZ]:=seZ;
  SpinEditByReg[crI]:=seI;
  SpinEditByReg[crJ]:=seJ;
  SpinEditByReg[crPC]:=sePC;
  SpinEditByReg[crSP]:=seSP;
  SpinEditByReg[crO]:=seO;
  {$IFDEF WINDOWS}
  lbDisassembly.Font.Name:='FixedSys';
  lbMemoryDump.Font.Name:='FixedSys';
  mMessages.Font.Name:='FixedSys';
  mCode.Font.Name:='FixedSys';
  mCode.ExtraCharSpacing:=-1;
  mCode.ExtraLineSpacing:=0;
  {$ELSE}
  lbDisassembly.Font.Name:=mCode.Font.Name;
  lbMemoryDump.Font.Name:=mCode.Font.Name;
  mMessages.Font.Name:=mCode.Font.Name;
  {$ENDIF}
  S:='';
  for I:=0 to $FFFF do S:=S + LineEnding;
  lbMemoryDump.Items.Text:=S;
  lbDisassembly.Items.Text:=S;
  FCPU:=TCPU.Create(Self);
  CPU.OnMemoryChange:=@OnMemoryChange;
  CPU.OnRegisterChange:=@OnRegisterChange;
  LastKnownProgramSize:=$FFFF;
  Reset;
  DisassembleFrom(0, $FFFF);
  lbDisassembly.ItemIndex:=0;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ScreenBitmap);
end;

procedure TMain.lbDisassemblyDblClick(Sender: TObject);
begin
  if lbDisassembly.ItemIndex > -1 then begin
    Breakpoint[lbDisassembly.ItemIndex]:=not Breakpoint[lbDisassembly.ItemIndex];
    lbDisassembly.Repaint
  end;
end;

procedure TMain.lbDisassemblyDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  Style: TTextStyle;
begin
  with Style do begin
    Alignment:=taLeftJustify;
    Layout:=tlCenter;
    SingleLine:=True;
    Clipping:=False;
    ExpandTabs:=False;
    ShowPrefix:=False;
    Wordbreak:=False;
    Opaque:=False;
    SystemFont:=False;
    RightToLeft:=False;
  end;
  with lbDisassembly.Canvas do begin
    Font.Assign(lbDisassembly.Font);
    if odSelected in State then begin
      Brush.Color:=clHighlight;
      Font.Color:=clHighlightText;
    end else begin
      Brush.Color:=clWindow;
      Font.Color:=clWindowText;
    end;
    Pen.Color:=Brush.Color;
    Rectangle(ARect);
    TextRect(ARect, 20, ARect.Top + ((ARect.Bottom - ARect.Top) - TextHeight('W')) div 2, DisassembledLines[Index], Style);
    if Breakpoint[Index] then
      ilIcons.Draw(lbDisassembly.Canvas, 2, ARect.Top + ((ARect.Bottom - ARect.Top) - 16) div 2, 1, gdeNormal);
    if ExecutedMark[Index] then
      ilIcons.Draw(lbDisassembly.Canvas, 2, ARect.Top + ((ARect.Bottom - ARect.Top) - 16) div 2, 0, gdeNormal);
  end;
end;

procedure TMain.lbMemoryDumpDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  Style: TTextStyle;
begin
  with Style do begin
    Alignment:=taLeftJustify;
    Layout:=tlCenter;
    SingleLine:=True;
    Clipping:=False;
    ExpandTabs:=False;
    ShowPrefix:=False;
    Wordbreak:=False;
    Opaque:=False;
    SystemFont:=False;
    RightToLeft:=False;
  end;
  with lbMemoryDump.Canvas do begin
    Font.Assign(lbMemoryDump.Font);
    if odSelected in State then begin
      Brush.Color:=clHighlight;
      Font.Color:=clHighlightText;
    end else begin
      Brush.Color:=clWindow;
      Font.Color:=clWindowText;
    end;
    Pen.Color:=Brush.Color;
    Rectangle(ARect);
    TextRect(ARect, 2, ARect.Top + ((ARect.Bottom - ARect.Top) - TextHeight('W')) div 2,
      HexStr(Index, 4) + ' (' + Format('%05d', [Index]) + '): ' + HexStr(CPU[Index], 4) + ' (' + Format('%05d', [CPU[Index]]) + ')',
      Style);
  end;

end;

procedure TMain.mAssemblyAssembleClick(Sender: TObject);
begin
  btAssembleClick(Sender);
end;

procedure TMain.mAssemblyRemoveBreakpointsClick(Sender: TObject);
var
  I: Integer;
begin
  for I:=0 to High(Breakpoint) do Breakpoint[I]:=False;
end;

procedure TMain.mCPUFullResetClick(Sender: TObject);
var
  I: Integer;
begin
  Reset;
  IgnoreFollow:=True;
  for I:=0 to High(TMemoryAddress) do CPU[I]:=0;
  IgnoreFollow:=False;
  DisassembleFrom(0, High(TMemoryAddress));
  UpdateAllMonitors;
end;

procedure TMain.mCPULoadProgramClick(Sender: TObject);
var
  Size: Integer;
begin
  if odProgram.Execute then begin
    try
      Reset;
      Size:=CPU.LoadProgramFromFile(odProgram.FileName);
      WriteMessage('Loaded ' + IntToStr(Size) + ' words of program code');
      DisassembleFrom(0, Size);
    except
      MessageDlg('Error', 'Failed to load program code from the file ' + odProgram.FileName + ': ' + Exception(ExceptObject).Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMain.mCPUResetClick(Sender: TObject);
begin
  Reset;
end;

procedure TMain.mCPUSaveProgramClick(Sender: TObject);
begin
  if FileName='' then
    sdProgram.FileName:=''
  else
    sdProgram.FileName:=ExtractFileNameWithoutExt(FileName) + '.dcpu16';
  if sdProgram.Execute then begin
    try
      CPU.SaveProgramToFile(sdProgram.FileName, LastKnownProgramSize);
      WriteMessage('Wrote ' + IntToStr(LastKnownProgramSize) + ' words of program code');
    except
      MessageDlg('Error', 'Failed to save the program to file ' + sdProgram.FileName, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMain.mCPUSingleStepClick(Sender: TObject);
begin
  SingleStep;
  DrawScreen;
end;

procedure TMain.mCPUUseBigEndianWordsClick(Sender: TObject);
begin
  mCPUUseBigEndianWords.Checked:=not mCPUUseBigEndianWords.Checked;
  CPU.UseBigEndianWords:=mCPUUseBigEndianWords.Checked;
end;

procedure TMain.mFileNewClick(Sender: TObject);
begin
  if ConfirmOk then begin
    mCode.ClearAll;
    mCode.ClearUndo;
    mCode.Modified:=False;
    FileName:='';
    Reset;
  end;
end;

procedure TMain.mFileOpenClick(Sender: TObject);
begin
  if not ConfirmOk then Exit;
  odCode.FileName:=FileName;
  if odCode.Execute then begin
    try
      mCode.Lines.LoadFromFile(odCode.FileName);
      FileName:=odCode.FileName;
      mCode.Modified:=False;
      Reset;
      mAssemblyAssembleClick(Sender);
    except
      MessageDlg('Error', 'Failed to open file ' + odCode.FileName, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMain.mFileQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.mFileSaveAsClick(Sender: TObject);
begin
  sdCode.FileName:=FileName;
  if sdCode.Execute then begin
    FileName:=sdCode.FileName;
    mFileSaveClick(Sender);
  end;
end;

procedure TMain.mFileSaveClick(Sender: TObject);
begin
  if FileName='' then begin
    mFileSaveAsClick(Sender);
    Exit;
  end;
  try
    mCode.Lines.SaveToFile(FileName);
    FileName:=sdCode.FileName;
    mCode.MarkTextAsSaved;
    mCode.Modified:=False;
  except
    MessageDlg('Error', 'Failed to save file ' + FileName + ': ' + Exception(ExceptObject).Message, mtError, [mbOK], 0);
  end;
end;

procedure TMain.mHelpAboutClick(Sender: TObject);
begin
  ShowMessage('DCPU-16 Studio version 20120406' + LineEnding + 'Copyright (C) 2012 by Kostas Michalopoulos' + LineEnding + LineEnding + 'Made using FreePascal, Lazarus and the SynEdit editor component.');
end;

procedure TMain.mHelpContentsClick(Sender: TObject);
begin
  LazHelpWindowedViewer1.ShowHelp;
end;

procedure TMain.mViewClearMessagesClick(Sender: TObject);
begin
  mMessages.Text:='';
end;

procedure TMain.mViewUserScreenClick(Sender: TObject);
begin
  UserScreen.Visible:=True;
  UserScreen.BringToFront;
end;

procedure TMain.pbScreenPaint(Sender: TObject);
begin
  DrawScreen;
end;

procedure TMain.seAChange(Sender: TObject);
begin
  CPU.CPURegister[crA]:=seA.Value;
end;

procedure TMain.seBChange(Sender: TObject);
begin
  CPU.CPURegister[crB]:=seB.Value;
end;

procedure TMain.seCChange(Sender: TObject);
begin
  CPU.CPURegister[crC]:=seC.Value;
end;

procedure TMain.seIChange(Sender: TObject);
begin
  CPU.CPURegister[crI]:=seI.Value;
end;

procedure TMain.seJChange(Sender: TObject);
begin
  CPU.CPURegister[crJ]:=seJ.Value;
end;

procedure TMain.seOChange(Sender: TObject);
begin
  CPU.CPURegister[crO]:=seO.Value;
end;

procedure TMain.sePCChange(Sender: TObject);
begin
  CPU.CPURegister[crPC]:=sePC.Value;
end;

procedure TMain.seSPChange(Sender: TObject);
begin
  CPU.CPURegister[crSP]:=seSP.Value;
end;

procedure TMain.seXChange(Sender: TObject);
begin
  CPU.CPURegister[crX]:=seX.Value;
end;

procedure TMain.seYChange(Sender: TObject);
begin
  CPU.CPURegister[crY]:=seY.Value;
end;

procedure TMain.seZChange(Sender: TObject);
begin
  CPU.CPURegister[crZ]:=seZ.Value;
end;

procedure TMain.btResetClick(Sender: TObject);
begin
  Reset;
end;

procedure TMain.ApplicationProperties1Idle(Sender: TObject; var Done: Boolean);
var
  CyclesToRun: Integer;
  Reg: TCPURegister;
begin
  Done:=False;
  NowTicks:=GetTickCount;
  if Running then begin
    if CycleExact then begin
      for Reg:=crA to crO do
        SpinEditByReg[Reg].Color:=clDefault;
      try
        while NowTicks - LastTicks > 10 do begin
          CyclesToRun:=1000;
          while CyclesToRun > 1 do begin
            CPU.RunCycle;
            Dec(CyclesToRun);
            if not Running then Break;
          end;
          Inc(LastTicks, 10);
        end;
      except
        on EDCPU16Exception do begin
          cbRunning.Checked:=False;
          WriteMessage('DCPU-16 Exception: ' + Exception(ExceptObject).Message);
          MessageDlg('DCPU-16 Exception', Exception(ExceptObject).Message, mtError, [mbOK], 0);
        end;
      end;
    end else
      SingleStep;
    DrawScreen;
  end else Sleep(1);
end;

procedure TMain.btAssembleClick(Sender: TObject);
var
  Ass: TAssembler;
  I: Integer;
  MemDump: string;
begin
  Ass:=TAssembler.Create;
  IgnoreFollow:=True;
  try
    WriteMessage('Assembling...');
    Ass.Assemble(mCode.Text);
    Reset;
    IgnoreFollow:=True;
    if Ass.Error then begin
      WriteMessage('Assembly error: ' + Ass.ErrorMessage);
      mCode.SelStart:=Ass.ErrorPos;
      mCode.SetFocus;
      MessageDlg('Error in code', Ass.ErrorMessage, mtError, [mbOK], 0);
    end else begin
      MemDump:='Memory Dump:' + LineEnding + '  0000:';
      for I:=0 to Ass.Size - 1 do begin
        MemDump:=MemDump + ' ' + HexStr(Ass[I], 4);
        if (I and 7)=7 then
          MemDump:=MemDump + LineEnding + '  ' + HexStr(I + 1, 4) + ':';
        CPU[I]:=Ass[I];
      end;
      WriteMessage(MemDump);
      WriteMessage('Symbol Map:');
      for I:=0 to Ass.SymbolCount - 1 do
        WriteMessage('  ' + HexStr(Ass.Symbols[I].Address, 4) + '  ' + Ass.Symbols[I].Name);
    end;
    DisassembleFrom(0, Ass.Size);
    LastKnownProgramSize:=Ass.Size;
  except
    WriteMessage('Assembly failed due to an internal error: ' + Exception(ExceptObject).Message);
  end;
  FreeAndNil(Ass);
  IgnoreFollow:=False;
  UpdateAllMonitors;
end;

procedure TMain.btSingleStepClick(Sender: TObject);
begin
  SingleStep;
  DrawScreen;
end;

procedure TMain.cbCycleExactChange(Sender: TObject);
begin
  CPU.CycleExact:=cbCycleExact.Checked;
  CycleExact:=CPU.CycleExact;
  if CycleExact then begin
    LastTicks:=GetTickCount;
  end else begin
    UpdateAllMonitors;
  end;
end;

procedure TMain.cbRunningChange(Sender: TObject);
begin
  Running:=cbRunning.Checked;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=ConfirmOk;
end;

procedure TMain.OnMemoryChange(ASender: TObject; MemoryAddress: TMemoryAddress;
  var MemoryValue: Word);
begin
  if CycleExact then Exit;
  if not IgnoreFollow then lbMemoryDump.Invalidate;
  if cbFollow.Checked and not IgnoreFollow then begin
    lbMemoryDump.ItemIndex:=MemoryAddress;
    Application.ProcessMessages;
  end;
end;

procedure TMain.OnRegisterChange(ASender: TObject; CPURegister: TCPURegister;
  var RegisterValue: Word);
begin
  if not CycleExact then begin
    SpinEditByReg[CPURegister].Value:=RegisterValue;
    SpinEditByReg[CPURegister].Color:=clYellow;
  end;
  if CPURegister=crPC then begin
    if not CycleExact then begin
      if CPU.SkipInstruction then
        lbNextInstructionState.Caption:='The next will instruction will be skipped'
      else
        lbNextInstructionState.Caption:='The next will instruction will be executed';
      lbLastCycles.Caption:='Last instruction cycles: ' + IntToStr(CPU.Cycles);
    end;
    if InstructionAddresses[RegisterValue] <> -1 then begin
      ExecutedMark[InstructionAddresses[RegisterValue]]:=True;
      if not CycleExact then begin
        if cbFollow.Checked and not IgnoreFollow and (InstructionAddresses[RegisterValue] < lbDisassembly.Count) then
          lbDisassembly.ItemIndex:=InstructionAddresses[RegisterValue];
      end;
      if Breakpoint[InstructionAddresses[RegisterValue]] then begin
        WriteMessage('Breakpoint at ' + HexStr(RegisterValue, 4));
        UpdateAllMonitors;
        cbRunning.Checked:=False;
        cbCycleExact.Checked:=False;
      end;
    end;
  end;
end;

procedure TMain.DisassembleFrom(Address, EndAddress: TMemoryAddress);
var
  I: Integer;
  StartAddress: TMemoryAddress;
begin
  for I:=0 to High(InstructionAddresses) do InstructionAddresses[I]:=-1;
  I:=0;
  while Address <= EndAddress do begin
    InstructionAddresses[Address]:=I;
    StartAddress:=Address;
    DisassembledLines[I]:=HexStr(Address, 4) + ': ' + CPU.DisassembleInstructionAt(Address);
    Inc(I);
    if StartAddress >= Address then Break;
  end;
  UpdateAllMonitors;
end;

procedure TMain.SetFileName(const AValue: string);
begin
  if FFileName=AValue then Exit;
  FFileName:=AValue;
  if FileName='' then
    Caption:='DCPU-16 Studio'
  else
    Caption:=ExtractFileName(FileName) + ' - DCPU-16 Studio';
end;

procedure TMain.SingleStep;
var
  Reg: TCPURegister;
begin
  for Reg:=crA to crO do
    SpinEditByReg[Reg].Color:=clDefault;
  try
    CPU.RunInstruction;
  except
    on EDCPU16Exception do begin
      cbRunning.Checked:=False;
      WriteMessage('DCPU-16 Exception: ' + Exception(ExceptObject).Message);
      MessageDlg('DCPU-16 Exception', Exception(ExceptObject).Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMain.Reset;
var
  Reg: TCPURegister;
  I: Integer;
begin
  IgnoreFollow:=True;
  WriteMessage('Resetting');
  LastTicks:=GetTickCount;
  for I:=0 to High(ExecutedMark) do ExecutedMark[I]:=False;
  CPU.Reset;
  for Reg:=crA to crO do begin
    PrevRegValues[Reg]:=CPU.CPURegister[Reg];
    SpinEditByReg[Reg].Color:=clDefault;
  end;
  cbRunning.Checked:=False;
  if lbDisassembly.Items.Count > 0 then lbDisassembly.ItemIndex:=0;
  lbMemoryDump.ItemIndex:=0;
  LastKnownProgramSize:=$FFFF;
  WriteMessage('Reset done');
  IgnoreFollow:=False;
end;

procedure TMain.DrawScreen;
var
  X, Y, Addr: Integer;
  Raw: TRawImage;
  PixelBuffer: PColor;

  procedure DrawChar(X, Y: Integer; Cell: Word);
  const
    {$IFDEF WINDOWS}
    RealColors: array [0..15] of TColor =
                 ($101010, $1000AA, $10AA10, $10AAAA, $AA1010, $AA10AA, $AA5010,
                  $AAAAAA, $808080, $1010ff, $10FF10, $10FFFF, $FF1010, $FF10FF,
                  $FFFF10, $FFFFFF);
    {$ELSE}
    RealColors: array [0..15] of TColor =
                 ($FF101010, $FFAA1010, $FF10AA10, $FFAAAA10, $FF1010AA, $FFAA10AA, $FF1050AA,
                  $FFAAAAAA, $FF808080, $FFFF1010, $FF10FF10, $FFFFFF10, $FF1010FF, $FFFF10FF,
                  $FF10FFFF, $FFFFFFFF);
    {$ENDIF}
  var
    Ch: Word;
    C, B: TColor;
    IX, IY: Integer;
  begin
    Ch:=Cell and $FF;
    C:=RealColors[(Cell and $F000) shr 12];
    B:=RealColors[(Cell and $0F00) shr 8];
    if Ch > $7F then begin
      Ch:=Ch and $7F;
      if ((NowTicks shr 8) and 1)=1 then C:=B;
    end;
    for IY:=0 to 7 do
      for IX:=0 to 3 do begin
        if Fnt[Ch][IX, IY] then
          PixelBuffer[(Y + IY)*(Raw.Description.BytesPerLine shr 2) + X + IX]:=C
        else
          PixelBuffer[(Y + IY)*(Raw.Description.BytesPerLine shr 2) + X + IX]:=B;
      end;
  end;

begin
  ScreenBitmap.BeginUpdate(False);
  Raw:=ScreenBitmap.RawImage;
  PixelBuffer:=PColor(Raw.Data);
  Addr:=VideoStart;
  for Y:=0 to 15 do
    for X:=0 to 31 do begin
      DrawChar(X*4, Y*8, CPU[Addr]);
      Inc(Addr);
    end;
  ScreenBitmap.EndUpdate(False);
  //pbScreen.Canvas.CopyRect(Rect(0, 0, 128, 128), ScreenBitmap.Canvas, Rect(0, 0, 128, 128));
  pbScreen.Canvas.Draw(0, 0, ScreenBitmap);
  if UserScreen.Visible then UserScreen.pbScr.Canvas.StretchDraw(Rect(0, 0, 511, 511), ScreenBitmap);
end;

function TMain.ConfirmOk: Boolean;
begin
  if not mCode.Modified then Exit(True);
  Result:=MessageDlg('Modified', 'The code has been modified. If you continue you will lose the modifications. Do you really want to continue and lose them?', mtConfirmation, mbYesNo, 0)=mrYes;
end;

procedure TMain.UpdateAllMonitors;
var
  Reg: TCPURegister;
begin
  for Reg:=crA to crO do
    SpinEditByReg[Reg].Value:=CPU.CPURegister[Reg];
  lbDisassembly.Invalidate;
  lbMemoryDump.Invalidate;
  pbScreen.Repaint;
  if InstructionAddresses[CPU.CPURegister[crPC]] > -1 then
    lbDisassembly.ItemIndex:=InstructionAddresses[CPU.CPURegister[crPC]];
end;

procedure TMain.KeyWasTyped(Ch: Char);
begin
  if CPU[KeyboardAddress]=0 then CPU[KeyboardAddress]:=Ord(Ch) else Beep;
end;

end.
