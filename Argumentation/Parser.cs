using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Parser
{
    class Parser
    {
        public static Dictionary<String, HashSet<ProgramNode>> edb = new Dictionary<string, HashSet<ProgramNode>>();
        public static Dictionary<string, HashSet<ProgramNode>> idb = new Dictionary<string, HashSet<ProgramNode>>();
        public static Dictionary<String, HashSet<Tuple<String, String>>> depGraph = new Dictionary<string, HashSet<Tuple<String, String>>>();

        public static string startParsing(string input)
        {
            List<ProgramNode> program = new List<ProgramNode>();
            Grounder grounder = new Grounder();
            string prologInput = "";
            string errorMsg = "";
            string termRegex = @"[a-z]?[A-Za-z0-9]+\([A-Z][A-Za-z0-9]*(,[A-Z][A-Za-z0-9]*)*\)";
            //Test String for dependency graph creation.
            //string test = "asm(aasdd,b){X=1,2;}.t(X) <- [p(X),aasdd(X)].p(X)<- [r(X)].r(X) <-[aasdd(X)].";
            //string test = "asm(aasdd,b){X=1,2;}.t(X) <- [p(X),aasdd(X)]. p(X)<- [r(X)]. s(X) <- [r(X)].p(X)<-[r(X),t(X)].r(X) <-[aasdd(X)].";
            //string test = "asm(aasdd,b)\t {X=a, b, c,d;Y=1,2,3; }.asm(e,z) {X=1,2;Y=2,3;}. aba <- [c,d] {a, e ,f ,s , g ,ffdf}. Something something";
            //string test = "b(X)<-[] {X=1,2,3,4;}.";
            //string test = "b(X,A)<-[a(X,A)].asm(a(X,Y),bfg(Y)){X=1,2,3;Y=2,3;}.c(X,Y,Z)<-[]{X=1,2,3;Y=2,3,4;Z=Michael,George,John;";
            string test = input;
            string[] split = test.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string s in split)
            {
                string line = System.Text.RegularExpressions.Regex.Replace(s, @"\s", "");
                // if (s.Substring(0, 4).CompareTo(@"asm(") == 0)
                // TODO REGEX FOR DOMAIN DOES NOT CAPTURE ERRORS>> MUST CHANGE ACCORDINGLY. Matches just asm part and succeeds
                if (Regex.IsMatch(line, String.Format(@"asm\({0},{0}\)", termRegex) + @"(\{(([A-Z]+=[A-Za-z0-9])+(,[A-Za-z0-9])*;)+\})?"))
                {
                    //Match grouped Regex.                    
                    string[] seperators = new string[] { @"asm(", "){", "}" };
                    // Seperates in IDs and domain.
                    string[] tokens = line.Split(seperators, StringSplitOptions.RemoveEmptyEntries);
                    // Seperates in Assumption and Contrary.
                    Regex regex = new Regex(termRegex);
                    MatchCollection termMatches = regex.Matches(tokens[0]);
                    List<String> terms = termMatches.Cast<Match>().Select(match => match.Value).ToList();

                    string[] assumptionProps = terms[0].Split(new char[] { '(', ')' }, StringSplitOptions.RemoveEmptyEntries);
                    string[] contraryProps = terms[1].Split(new char[] { '(', ')' }, StringSplitOptions.RemoveEmptyEntries);

                    string assumption = assumptionProps[0];
                    string contrary = contraryProps[0];
                    string output = "";
                    // Generates all possible combinations of domain.
                    Dictionary<String, string[]> parsedDomain = parseDomain(tokens[1]);
                    string[] assumptionVars = assumptionProps[1].Split(',');
                    string[] contraryVars = contraryProps[1].Split(',');
                    string[] vars = assumptionVars.Union(contraryVars).ToArray();

                    string[][] assumDomain = getDomain(assumptionVars, parsedDomain);
                    string[][] contrDomain = getDomain(contraryVars, parsedDomain);
                    string[][] varsDomain = getDomain(vars, parsedDomain);

                    List<String[]> assumCombs = new List<String[]>();
                    List<String[]> contrCombs = new List<String[]>();
                    List<String[]> varsCombs = new List<String[]>();

                    //   createCombinations(assumDomain, assumptionVars.Length - 1, new string[assumptionVars.Length], assumCombs);
                    //    createCombinations(contrDomain, contraryVars.Length - 1, new string[contraryVars.Length], contrCombs);
                    createCombinations(varsDomain, vars.Length - 1, new string[vars.Length], varsCombs);


                    output = addToEDB(varsCombs, assumptionProps, contraryProps, assumptionVars, contraryVars, vars);
                    // TODO DELETE CODE BELOW WHEN SURE ITS OK.
                    //string[][] fulldomain = new string[2][];
                    //string[] variable = tokens[1].Split(',');
                    //fulldomain[0] = variable;
                    //fulldomain[1] = variable;
                    //foreach (String var1 in fulldomain[0])
                    //{
                    //    foreach (String var2 in fulldomain[1])
                    //    {
                    //        var parms = Tuple.Create(var1, var2);
                    //    }
                    //}

                    //        asmObject.variables = domain;
                    //      grounder.addToEDB(asmObject);
                    //string output = String.Format("myAsm({0}).\ncontrary({0},{1}).\n", assumption, contrary);
                    prologInput = prologInput + output;
                }
                else if (Regex.IsMatch(line, String.Format(@"{0}<-\[\]", termRegex) + @"(\{(([A-Z]+=[A-Za-z0-9])+(,[A-Za-z0-9])*;)+\})?"))
                {
                    string[] seperators = new string[] { @"<-", "[", "]", "{", "}" };
                    string[] tokens = line.Split(seperators, StringSplitOptions.RemoveEmptyEntries);
                    string output = "";

                    string rule = tokens[0];
                    Literal head = getHead(rule);

                    Dictionary<String, string[]> parsedDomain = parseDomain(tokens[1]);
                    string[][] varsDomain = getDomain(head.variables, parsedDomain);
                    List<String[]> varsCombs = new List<String[]>();
                    createCombinations(varsDomain, head.variables.Length - 1, new string[head.variables.Length], varsCombs);

                    output = addToEDB(varsCombs, head);

                    prologInput = prologInput + output;
                }
                else if (Regex.IsMatch(line, String.Format(@"{0}<-\[{0}(,{0})*\]", termRegex)))
                {
                    string[] seperators = new string[] { @"<-", "[", "]", "{", "}" };
                    string[] tokens = line.Split(seperators, StringSplitOptions.RemoveEmptyEntries);

                    string rule = tokens[0];
                    Literal head = getHead(rule);

                    Regex regex = new Regex(termRegex);
                    MatchCollection termMatches = regex.Matches(tokens[1]);
                    List<String> terms = termMatches.Cast<Match>().Select(match => match.Value).ToList();
                    List<Literal> termList = getTerms(terms);
                    // TODO Domain needs fixing for Rule parsing.
                    string[] domain = null;
                    if (tokens.Length > 2)
                    {
                        domain = tokens[2].Split(',');
                    }

                    Rule ruleObj = new Rule(head.id, termList, head.variables);
                    addToDepGraph(ruleObj);
                    if (idb.ContainsKey(ruleObj.id))
                        idb[ruleObj.id].Add(ruleObj);
                    else
                    {
                        HashSet<ProgramNode> ruleTemp = new HashSet<ProgramNode>();
                        ruleTemp.Add(ruleObj);
                        idb.Add(ruleObj.id, ruleTemp);
                    }
                    program.Add(ruleObj);
                    string output = String.Format("myRule({0}, [{1}]).\n", rule, tokens[1]);
                    //    prologInput = prologInput + output;
                }
                else
                {
                    errorMsg = errorMsg + "Invalid statement: " + s + "\n";
                }
            }
            Graph graphC = SCC.generateComponentGraph(depGraph);

            List<HashSet<Node>> sccOrder = new List<HashSet<Node>>();
            sccOrder = deriveOrdering(graphC);

            List<ProgramNode> groundedProgram = Grounder.instantiate(graphC, program, sccOrder, edb);
            foreach (var rule in groundedProgram)
            {
                string headVars;
                if (rule.variables != null)
                {
                    headVars = String.Format("({0})", String.Join(",", rule.variables));
                }
                else
                {
                    headVars = "";
                }
                string head = String.Format("{0}{1}", rule.id, headVars);
                Rule tempRule = (Rule)rule;
                List<String> predList = new List<String>();
                foreach (var pred in tempRule.predicates)
                {
                    string predString;
                    if (rule.variables != null)
                    {
                        predString = String.Format("({0})", String.Join(",", pred.variables));
                    }
                    else
                    {
                        predString = "";
                    }
                    predString = pred.id + predString;
                    predList.Add(predString);
                }
                String preds = String.Join(",", predList);
                string line = String.Format("myRule({0}, [{1}]).\n", head, preds);
                prologInput = prologInput + line;
            }
            return prologInput;
        }

        private static string[][] getDomain(string[] vars, Dictionary<string, string[]> parsedDomain)
        {
            string[][] mappeddomain = new string[vars.Length][];
            int index = 0;
            foreach (var var in vars)
            {
                mappeddomain[index] = parsedDomain[var];
                index++;
            }
            return mappeddomain;
        }

        private static List<Literal> getTerms(List<String> terms)
        {
            List<Literal> termList = new List<Literal>();
            foreach (var term in terms)
            {
                Literal newterm = new Literal();
                string[] parts = term.Split(new char[] { '(', ')' });
                newterm.id = parts[0];
                newterm.variables = parts[1].Split(',');
                termList.Add(newterm);
            }
            return termList;
        }

        private static Literal getHead(string p)
        {

            string[] elements = p.Split(new char[] { '(', ')' });
            Literal lit = new Literal();
            lit.id = elements[0];
            lit.variables = elements[1].Split(',');
            return lit;
        }

        private static List<HashSet<Node>> deriveOrdering(Graph graphC)
        {
            List<HashSet<Node>> ordering = new List<HashSet<Node>>();
            foreach (var component in graphC.nodes)
            {
                // Add first element to order list.
                if (ordering.Count() == 0)
                {
                    ordering.Add(component);
                }
                else
                {
                    int index = 0;
                    foreach (var elem in ordering)
                    {
                        if (graphC.edges.Contains(Tuple.Create(component, elem)))
                        {
                            ordering.Insert(index, component);
                            break;
                        }
                        else if (ordering.Last() == elem)
                        {
                            ordering.Add(component);
                            break;
                        }
                        else
                            index++;
                    }
                }
            }
            return ordering;
        }
        // Used to build Dependency graph for grounder at incrementally for each rule parsed.
        private static void addToDepGraph(Rule rule)
        {
            // Check if rule already recorded in Graph.
            if (depGraph.ContainsKey(rule.id))
            {
                // Gets existing Predicates recorded so far.
                HashSet<Tuple<String, String>> existPreds = depGraph[rule.id];
                // Creates and appends any new predicates.
                foreach (var pred in rule.predicates)
                {
                    if (!edb.ContainsKey(pred.id))
                        existPreds.Add(Tuple.Create(pred.id, rule.id));
                }
                // Replaces with updated set.
                depGraph[rule.id] = existPreds;
            }
            // Same as above.
            else
            {
                HashSet<Tuple<String, String>> newPreds = new HashSet<Tuple<String, String>>();
                foreach (var pred in rule.predicates)
                {
                    if (!edb.ContainsKey(pred.id))
                        newPreds.Add(Tuple.Create(pred.id, rule.id));
                }
                depGraph.Add(rule.id, newPreds);
            }
        }

        public static String addToEDB(List<string[]> combinations, string[] assumptionProps, string[] contraryProps, string[] assumptionVars, string[] contraryVars, string[] vars)
        {
            string combString = "";
            string assumptionID = assumptionProps[0];
            string contraryID = contraryProps[0];
            foreach (var comb in combinations)
            {
                int index = 0;
                Dictionary<String, String> combDict = new Dictionary<string, string>();
                foreach (var v in vars)
                {
                    combDict.Add(v, comb[index]);
                    index++;
                }

                string[] assumComb = new string[assumptionVars.Length];
                int assumIndex = 0;
                foreach (var v in assumptionVars)
                {
                    assumComb[assumIndex] = combDict[v];
                    assumIndex++;
                }

                string[] contComb = new string[contraryVars.Length];
                int contIndex = 0;
                foreach (var v in contraryVars)
                {
                    contComb[contIndex] = combDict[v];
                    contIndex++;
                }

                Assumption assumption = new Assumption();
                assumption.id = assumptionID;
                assumption.variables = assumComb;
                string assumString = String.Format("myAsm({0}({1})).\n", assumption.id, String.Join(",", assumption.variables));

                Assumption contrary = new Assumption();
                contrary.id = contraryID;
                contrary.variables = contComb;
                string contString = String.Format("contrary({0}({1}),{2}({3})).\n", assumption.id, String.Join(",", assumption.variables), contrary.id, String.Join(",", contrary.variables));


                if (edb.ContainsKey(assumptionID))
                {
                    HashSet<ProgramNode> existAsm = edb[assumptionID];
                    existAsm.Add(assumption);
                    edb[assumptionID] = existAsm;

                    HashSet<ProgramNode> existCont = edb[contraryID];
                    existCont.Add(contrary);
                    edb[contraryID] = existCont;
                }
                else
                {
                    HashSet<ProgramNode> newAsm = new HashSet<ProgramNode>();
                    newAsm.Add(assumption);
                    edb.Add(assumptionID, newAsm);

                    HashSet<ProgramNode> newCont = new HashSet<ProgramNode>();
                    newCont.Add(contrary);
                    edb.Add(contraryID, newCont);
                }
                combString = combString + assumString + contString;
            }
            return combString;
        }

        private static string addToEDB(List<string[]> combinations, Literal head)
        {
            string combString = "";
            foreach (var comb in combinations)
            {
                Rule ruleObj = new Rule(head.id, null, comb);
                string ruleString = String.Format("myRule({0}({1}), []).\nh", head.id, String.Join(",", comb));

                if (edb.ContainsKey(head.id))
                {
                    HashSet<ProgramNode> existRule = edb[head.id];
                    existRule.Add(ruleObj);
                    edb[head.id] = existRule;
                }
                else
                {
                    HashSet<ProgramNode> newRule = new HashSet<ProgramNode>();
                    newRule.Add(ruleObj);
                    edb.Add(head.id, newRule);
                }
                combString = combString + ruleString;
            }
            return combString;
        }

        public static Dictionary<String, String[]> parseDomain(string domain)
        {

            // TEST STRING 
            // string domain = "X=1,2,3;Y=1,2;";            
            String[] variables = domain.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
            Dictionary<String, String[]> parsedDomain = new Dictionary<string, String[]>();
            foreach (String variable in variables)
            {
                String[] varElems = variable.Split('=');
                parsedDomain.Add(varElems[0], varElems[1].Split(','));
            }

            //int numVariable = parsedDomain.Length-1;
            //string[] combination = new string[parsedDomain.Length];
            //List<string[]> final = new List<string[]>();
            //createCombinations(parsedDomain, numVariable, combination, final);
            return parsedDomain;
        }

        private static void createCombinations(string[][] parsedDomain, int numVariable, string[] combination, List<string[]> final)
        {
            if (numVariable == 0)
            {
                foreach (var elem in parsedDomain[0])
                {
                    combination[0] = elem;
                    string[] addComb = new string[parsedDomain.Length];
                    addComb = (string[])combination.Clone();
                    final.Add(addComb);
                }
            }
            else
            {
                foreach (var elem in parsedDomain[numVariable])
                {
                    combination[numVariable] = elem;
                    createCombinations(parsedDomain, numVariable - 1, combination, final);
                }
            }
        }

    }
}
