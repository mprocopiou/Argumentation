<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Assumptions.aspx.cs" Inherits="Argumentation.Assumptions" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <table>
        <tr>
            <td>
                <asp:Label runat="server" ID="AssumptionNameText" Text="Assumption: " />                
                <asp:ComboBox AutoCompleteMode="Suggest" ID="AssumptionName" runat="server"></asp:ComboBox>
            </td>
            <td>
                <asp:Label runat="server" ID="ContraryNameText" Text="Contrary: " />                
                <asp:ComboBox AutoCompleteMode="Suggest" ID="ContraryName" runat="server"></asp:ComboBox>
            </td>            
        </tr>
        <tr>
            <td>
                <asp:Button runat="server" ID="AddAnotherAssumption" Text="Add More" OnClick="AddAnotherAssumption_Click" />
            </td>
            <td>
                <asp:Button runat="server" ID="AssumptionsDone" Text="Done" OnClick="AssumptionsDone_Click" />
            </td>
        </tr>
    </table>
</asp:Content>