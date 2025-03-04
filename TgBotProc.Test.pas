﻿unit TgBotProc.Test;

interface

uses
  System.SysUtils, TgBotApi, TgBotApi.Client;

[TTgUpdateSubscribe]

function ProcMenu(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function ProcStart(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function ProcInfo(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function ProcA(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function ProcPhoto(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function ProcCallbackQuery(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function UploadAllFiles(u: TtgUpdate): Boolean;

[TTgUpdateSubscribe]

function Logging(u: TtgUpdate): Boolean;

implementation

uses
  System.Classes, System.IOUtils, IdSMTP, IdMessage, IdAttachmentFile,
  IdExplicitTLSClientServerBase, IdSSLOpenSSL;

procedure SendMailFile(const Comment, AFile: string);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
begin
  if not TFile.Exists(AFile) then
    Exit;
  Msg := TIdMessage.Create(nil);
  try
    Msg.From.Address := '@mail.ru';
    Msg.Recipients.EMailAddresses := '@inbox.ru';
    Msg.Body.Text := Comment;
    TIdAttachmentFile.Create(Msg.MessageParts, AFile);
    Msg.CharSet := 'utf-8';
    Msg.Subject := AFile;
    SMTP := TIdSMTP.Create(nil);
    try
      SMTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
      SMTP.Host := 'smtp.mail.ru';
      SMTP.Port := 25;
      SMTP.AuthType := satDefault;
      SMTP.UseTLS := utUseRequireTLS;
      SMTP.Username := '@mail.ru';
      SMTP.Password := '';
      SMTP.Connect;
      SMTP.Send(Msg);
    finally
      SMTP.Free;
    end;
  finally
    Msg.Free;
  end;
end;

function Logging(u: TtgUpdate): Boolean;
begin
  Result := False;
  Writeln('Data: ', u.ToString);
end;

function UploadAllFiles(u: TtgUpdate): Boolean;
const
  UploadPath = 'D:\Temp\';
begin
  Result := False;
  if Assigned(u.Message) and Assigned(u.Message.Document) then
  begin
    var FileName := UploadPath + u.Message.Document.FileName;
    var FileNameTemp := UploadPath + u.Message.Document.FileName + '.tmp';
    var FileStream := TFileStream.Create(FileNameTemp, fmCreate);
    try
      try
        Client.GetFile(u.Message.Document.FileId, FileStream);
      finally
        FileStream.Free;
      end;
      TFile.Move(FileNameTemp, FileName);
      SendMailFile('Файл из Телеги', FileName);
      TFile.Delete(FileName);
    except
      TFile.Delete(FileNameTemp);
    end;
  end;
end;

function ProcMenu(u: TtgUpdate): Boolean;
begin
  Result := False;
  var KeyBoard := TtgInlineKeyboardMarkup.Create([
    [['🌦️ Погода', 'command1'], ['🥐 Еда', 'command2']],
    [['3', 'command3'], ['4', 'command4']]]);
  Client.SendMessageToChat(u.Message.Chat.Id, 'Меню', KeyBoard.ToString(True)).Free;
end;

function ProcStart(u: TtgUpdate): Boolean;
begin
  Result := False;
  var KeyBoard := TtgReplyKeyboardMarkup.Create([
    ['1', '2'],
    ['3', '/info']
    ]);
  Client.SendMessageToChat(u.Message.Chat.Id, 'Меню 2', KeyBoard.ToString(True)).Free;
end;

function ProcInfo(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendMessageToChat(u.Message.Chat.Id, 'Нет информации').Free;
end;

function ProcA(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendMessageToChat(u.Message.Chat.Id, 'Не Ааа!').Free;
end;

function ProcPhoto(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendPhotoToChat(u.Message.Chat.Id, 'Фото', 'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png').Free;
end;

function ProcCallbackQuery(u: TtgUpdate): Boolean;
begin
  Result := False;
  if Assigned(u.CallbackQuery) and
    Assigned(u.CallbackQuery.Message) and
    Assigned(u.CallbackQuery.Message.Chat)
    then
  begin
    Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data).Free;
  end;
end;

end.

