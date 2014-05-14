<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Result.aspx.cs" Inherits="Argumentation.Result" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
<iframe src="WebForm1.aspx?engine=<%= Request.QueryString["engine"] %>" width = 960 height = 500 scrolling="no" style="border:solid; background: #FFFFFF" />
</asp:Content>