<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Argumentation.About" %>
<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    <div>
        <asp:TextBox Rows="10" TextMode="MultiLine" runat="server" id="framework"/>
    </div>
    <div>
        <asp:TextBox runat="server" id="claim"/>
    </div>
    <div>
        <asp:Button runat="server" ID="Submit" OnClick="Submit_Click" Text="Submit" />  
    </div>
    <asp:HiddenField runat="server" ID="jsonstream" />
</asp:Content>