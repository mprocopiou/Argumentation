<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rules.aspx.cs" Inherits="Argumentation.Rules" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <table>
        <tr>
            <td colspan="2">
                <asp:Label runat="server" ID="RuleNameText" Text="Rule name: " />                
                <asp:ComboBox AutoCompleteMode="Suggest" ID="RuleName" runat="server"></asp:ComboBox>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label runat="server" ID="SupportiveName" Text="Support: " />                
            </td>
            <td>
                <asp:DropDownList Style="width:200px" ID="Supportive" runat="server"></asp:DropDownList>
            </td>            
        </tr>
        <tr>
            <td>
                <asp:Label runat="server" ID="DisputeName" Text="Dispute: " />    
            </td>
            <td>            
                <asp:DropDownList Style="width:200px" Enabled="true" ID="Dispute" runat="server"></asp:DropDownList>
            </td>            
        </tr>
        <tr>
            <td>
                <asp:Button runat="server" ID="AddAnotherRule" Text="Add More" OnClick="AddAnotherRule_Click" />
            </td>
            <td>
                <asp:Button runat="server" ID="RulesDone" Text="Done" OnClick="RulesDone_Click" />
            </td>
        </tr>
    </table>
</asp:Content>
