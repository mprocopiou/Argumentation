<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Argumentation.About" %>
<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    <div>
        <asp:TextBox Rows="10" TextMode="MultiLine" runat="server" id="framework"/>
    </div>
    <div>
        <asp:TextBox runat="server" id="claim"/>
    </div>
    <div>
        <table>
            <tr>
                <td style="padding:0;"><asp:Label ID="AdmissibleText" runat="server" Text="Admissible" /></td>
                <td style="padding:0;">                    
                    <asp:RadioButton id="Admissible" Checked="true" GroupName="Semantics" runat="server" TextAlign="Left" /> 
                </td>
                <td style="padding:0;"><asp:Label ID="GroundedText" runat="server" Text="Grounded" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Grounded" GroupName="Semantics" runat="server" />
                </td>
                <td style="padding:0;"><asp:Label ID="IdealText" runat="server" Text="Ideal" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Ideal" GroupName="Semantics" runat="server" />
                </td>
            </tr>
            <tr>
                <td style="padding:0;"><asp:Label ID="ProxddText" runat="server" Text="Proxdd" /></td>
                <td style="padding:0;">                    
                    <asp:RadioButton id="Proxdd" Checked="true" GroupName="Engine" runat="server" TextAlign="Left" /> 
                </td>
                <td style="padding:0;"><asp:Label ID="GraphargText" runat="server" Text="Grapharg" /></td>
                <td style="padding:0;">
                    <asp:RadioButton id="Grapharg" GroupName="Engine" runat="server" />
                </td>
            </tr>
        </table>

        <%-- 
        <asp:RadioButtonList ID="SemanticsList" TextAlign="Left" RepeatLayout="Table" RepeatColumns="2" AutoPostBack="false" runat="server">
            <asp:ListItem Selected="True" Value="0" Text="Admissable"/>
            <asp:ListItem Value="1"  Text="Grounded"/>
        </asp:RadioButtonList>
            --%>
    </div>
    <div>
        <asp:Button runat="server" ID="Assumptions" OnClick="Assumption_Redirect" Text="Create Assumption" />  
        <asp:Button runat="server" ID="Rules" OnClick="Rule_Redirect" Text="Create Rule" />  
    </div>
    <div>
        <asp:Button runat="server" ID="Submit" OnClick="Submit_Click" Text="Submit" />  
    </div>
    <asp:HiddenField runat="server" ID="jsonstream" />
</asp:Content>