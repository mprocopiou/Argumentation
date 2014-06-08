<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Argumentation.About" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
            <ul class="nav nav-sidebar">
                <li class="active"><a href="#inputForm" data-toggle="tab">Input Configuration</a></li>
                <li><a href="#test" data-toggle="tab">Test</a></li>
            </ul>
        </div>
        <div class="tab-content">
            <div class="tab-pane active" id="inputForm">
                <div class="col-lg-10 col-lg-offset-2">
                    <div class="well bs-component">
                        <fieldset>
                            <legend>Current Configuration.</legend>
                            <div class="form-group">
                                <div class="col-lg-10 col-lg-offset-2">
                                    <asp:Repeater ID="ErrorRepeater" runat="server">
                                        <HeaderTemplate>
                                            <table class="table">
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <tr class="danger">
                                                <td><%# Container.DataItem %> </td>
                                            </tr>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </table>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="framework" class="col-lg-2 control-label">Input Framework</label>
                                <div class="col-lg-10">
                                    <asp:TextBox Rows="10" TextMode="MultiLine" CssClass="form-control" runat="server" ID="framework" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="claim" class="col-lg-2 control-label">Input Target</label>
                                <div class="col-lg-5">
                                    <asp:TextBox runat="server" CssClass="form-control" ID="claim" />
                                </div>
                                <div class="col-lg-5">
                                    <div class="alert alert-danger" id="SolutionNotFound" runat="server" visible="true">
                                        <asp:Label runat="server" ID="SolutionNotFoundText" Text="No Solution was found for the claim."></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 control-label">Derivation Engine</label>
                                <div class="col-lg-2">
                                    <asp:Label ID="ProxddText" runat="server" Text="Proxdd" />
                                    <asp:RadioButton ID="Proxdd" Checked="true" GroupName="Engine" runat="server" TextAlign="Left" />
                                </div>
                                <div class="col-lg-2">
                                    <asp:Label ID="GraphargText" runat="server" Text="Grapharg" />
                                    <asp:RadioButton ID="Grapharg" GroupName="Engine" runat="server" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 control-label">Semantics</label>
                                <div class="col-lg-2">
                                    <asp:Label ID="AdmissibleText" runat="server" Text="Admissible" />
                                    <asp:RadioButton ID="Admissible" Checked="true" GroupName="Semantics" runat="server" TextAlign="Left" />
                                </div>
                                <div class="col-lg-2">
                                    <asp:Label ID="GroundedText" runat="server" Text="Grounded" />
                                    <asp:RadioButton ID="Grounded" GroupName="Semantics" runat="server" />
                                </div>
                                <div class="col-lg-2">
                                    <asp:Label ID="IdealText" runat="server" Text="Ideal" />
                                    <asp:RadioButton ID="Ideal" GroupName="Semantics" runat="server" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-10 col-lg-offset-2">
                                    <asp:Button runat="server" ID="Submit" CssClass="btn btn-primary" OnClick="Submit_Click" Text="Submit" />
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </div>
            </div>

            <div class="tab-pane " id="test">
                testtest
            </div>
        </div>

    </div>

    <%-- 
        <asp:RadioButtonList ID="SemanticsList" TextAlign="Left" RepeatLayout="Table" RepeatColumns="2" AutoPostBack="false" runat="server">
            <asp:ListItem Selected="True" Value="0" Text="Admissable"/>
            <asp:ListItem Value="1"  Text="Grounded"/>
        </asp:RadioButtonList>
    --%>
    <%--    <div class="row">
        <asp:Button runat="server" ID="Assumptions" OnClick="Assumption_Redirect" Text="Create Assumption" />  
        <asp:Button runat="server" ID="Rules" OnClick="Rule_Redirect" Text="Create Rule" />  
    </div>--%>
    <asp:HiddenField runat="server" ID="jsonstream" />
    <script>
        $(function () {
            $('#myTab a:last').tab('show')
        })
    </script>
    </>
</asp:Content>
