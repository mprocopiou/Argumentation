    <%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="Argumentation.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<style>

.node {
  stroke: #fff;
  stroke-width: 1.5px;
}

.link {
  stroke: #999;
  stroke-opacity: .6;
}

.link.assumption {
  stroke-dasharray: 0,2 1;    
}

</style>
<script src="http://d3js.org/d3.v3.min.js"></script>
</head>
<body>
    <script>

        var width = 960,
            height = 500;

        var color = d3.scale.ordinal()
                    .domain([0, 1, 2, 3])
                    .range(["#7f7f7f", "#2ca02c", "#ff7f0e", "#AEC7E8"]);

        var lines = d3.scale.ordinal()
                    .domain([0, 1])
                    .range(["assumption", ""]);

        var force = d3.layout.force()
            .charge(-120)
            .linkDistance(30)
            .size([width, height]);

        var svg = d3.select("body").append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .call(d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", zoom))
            .append("g");

         svg.append('svg:rect')
            .attr('width', width)
            .attr('height', height)
            .attr('fill', 'white');

        var nodesData = [<%= nodesSet.Value %>];
        var linksData = [<%= linksSet.Value %>];

        d3.json("./Content/jsontest.js", function (error, graph) {
            force            
                .nodes(nodesData)
                .links(linksData)
                .start();

            var link = svg.selectAll(".link")
                .data(linksData)
              .enter().append("line")
                .attr("class", function (d) { return "link " + lines(d.group); })
                .style("stroke-width", function (d) { return Math.sqrt(d.value); });

            var node = svg.selectAll(".node")
                .data(nodesData)
              .enter().append("path")
                .attr("class", "node")
                .attr("d", d3.svg.symbol().type(function (d) { return d3.svg.symbolTypes[d.shape]; }))
                .style("fill", function (d) { return color(d.group); })
                .call(force.drag);

            node.append("title")
                .text(function (d) { return d.name; });

            force.on("tick", tick);

            function tick(e) {

                var k = 6 * e.alpha;
                linksData.forEach(function (d, i) {
                    d.source.x -= k;
                    d.target.x += k;
                });

                link.attr("x1", function (d) { return d.source.x; })
                    .attr("y1", function (d) { return d.source.y; })
                    .attr("x2", function (d) { return d.target.x; })
                    .attr("y2", function (d) { return d.target.y; });

                node.attr("cx", function (d) { return d.x; })
                    .attr("cy", function (d) { return d.y; })
                    .attr("transform", function (d) {return "translate(" + d.x + "," + d.y + ") scale(2)";});
            }
        });

        function zoom() {
            svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }
</script>
    <form id="form1" runat="server">
         <asp:HiddenField runat="server" ID="jsonstream"/>     
         <asp:HiddenField runat="server" ID="nodesSet" />
         <asp:HiddenField runat="server" ID="linksSet" />
    </form>
</body>
</html>
