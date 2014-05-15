using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Parser
{
    public class ProgramNode
    {
        public String id { get; set; }
        public String[] variables;
    }

    public class Assumption : ProgramNode
    {        
    }

    public class Literal
    {
        public String id { get; set; }
        public String[] variables { get; set; }

        public Literal(){}

        public Literal(String id, String[] variables)
        {
            this.id = id;
            this.variables = variables;
        }

    }

    public class Rule : ProgramNode
    {
        public List<Literal> predicates { get; set; }

        public Rule(String id, List<Literal> predicates, String[] variables)
        {
            this.id = id;
            this.predicates = predicates;
            this.variables = variables;
        }
    }

    class Grounder
    {
        public static HashSet<ProgramNode> S = new HashSet<ProgramNode>();

        internal static List<ProgramNode> instantiate(Graph graphC, List<ProgramNode> program, List<HashSet<Node>> sccOrder, Dictionary<String, HashSet<ProgramNode>> edb)
        {
            List<ProgramNode> groundedProgram = new List<ProgramNode>();
            foreach (var elem in edb.Values.ToArray())
            {
                S.UnionWith(elem);
            }            
            foreach (var component in sccOrder)
            {
                instantiateModule(program, component, S, groundedProgram);
            }
            return groundedProgram;
        }

        private static void instantiateModule(List<ProgramNode> program, HashSet<Node> component, HashSet<ProgramNode> S, List<ProgramNode> groundedProgram)
        {
            HashSet<ProgramNode> nS = new HashSet<ProgramNode>();
            HashSet<ProgramNode> deltaS = new HashSet<ProgramNode>();
            HashSet<ProgramNode> exitList = new HashSet<ProgramNode>();
            HashSet<ProgramNode> recursiveList = new HashSet<ProgramNode>();
            HashSet<String> componentIds = new HashSet<string>();

            foreach (var elem in component) 
            {
                componentIds.Add(elem.id);
            }

            foreach (var progNode in program)
            {
                if (componentIds.Contains(progNode.id))
                {
                    Rule rule = (Rule) progNode;
                    bool recursive = false;
                    foreach (var pred in rule.predicates)
                    {
                        if (componentIds.Contains(pred.id))
                        {
                            recursive = true;
                            break;
                        }
                    }
                    if (recursive)
                        recursiveList.Add(rule);
                    else
                        exitList.Add(rule);                    
                }
            }

            foreach (var rule in exitList)
            {
                instantiateRule(rule, S, deltaS, nS, groundedProgram);
            }

            do
            {
                deltaS = nS;
                nS = null;
                foreach (var rule in recursiveList)
                {
                    instantiateRule(rule, S, deltaS, nS, groundedProgram);
                }
                S.UnionWith(deltaS);
            } while (nS != null);
        }

        private static void instantiateRule(ProgramNode rule, HashSet<ProgramNode> S, HashSet<ProgramNode> deltaS, HashSet<ProgramNode> nS, List<ProgramNode> groundedProgram)
        {
            Stack<Stack<string[]>> varsRecord = new Stack<Stack<string[]>>();
            varsRecord.Push(null);
            Dictionary<String,String> theta = new Dictionary<string,string>();
            HashSet<Dictionary<String,String>> substitutions = new HashSet<Dictionary<string,string>>();
            bool matchfound = true;
            Rule r = (Rule) rule;
            List<Literal> preds = r.predicates;
            List<HashSet<String>> previousVars = getVariableLists(preds);
            int indexLit = 0;
            Literal literal = preds[0];
            while (!(indexLit < 0))
            {
                match(literal, theta, S, ref matchfound, varsRecord);
                if (matchfound)
                {
                    // Perhaps inequality is wrong! (Corrected and testing)
                    if (indexLit + 1 < preds.Count())
                        literal = preds[++indexLit];
                    else
                    {
                        Dictionary<String, String> newSub = new Dictionary<string, string>(theta);
                        //newSub = theta.;
                        substitutions.Add(newSub);
                        //Not sure if i should go to previous.
                        //literal = previousLiteral(preds, ref indexLit, ref literal);
                        matchfound = false;
                        var existingKeys = theta.Keys.ToArray();
                        foreach (var sub in existingKeys)
                        {
                            if (indexLit > -1 && !previousVars[indexLit].Contains(sub))
                                theta.Remove(sub);
                        }
                    }
                }
                else
                {
                    literal = previousLiteral(preds, ref indexLit, ref literal);
                    string[] tempKeys = theta.Keys.ToArray();
                    foreach (var sub in tempKeys)
                    {
                        if (indexLit > -1 && !previousVars[indexLit].Contains(sub))
                            theta.Remove(sub);
                    }
                    varsRecord.Pop();
                }
            }

            foreach (var sub in substitutions)
            {
                string[] headVar = getSub(sub, r.variables);
                List<Literal> tempLits = new List<Literal>();
                foreach (var pred in r.predicates)
                {
                    string[] predVars = getSub(sub, pred.variables);
                    Literal tempLit = new Literal(pred.id.ToString(),predVars);
                    tempLits.Add(tempLit);
                }
                Rule newRule = new Rule(r.id.ToString(), tempLits, headVar);
                S.Add(newRule);
                groundedProgram.Add(newRule);
            }
        }

        private static string[] getSub(Dictionary<string, string> sub, string[] p)
        {
            List<string> headVars = new List<string>();
            int index = 0;
            foreach (var elem in p)
            {
                headVars.Add(sub[elem].ToString());
                index++;
            }
            string[] finalVars = headVars.ToArray();
            return finalVars;
        }

        private static Literal previousLiteral(List<Literal> preds, ref int indexLit, ref Literal literal)
        {
            indexLit--;
            if (indexLit < 0)
                literal = null;
            else
                literal = preds[indexLit];
            return literal;
        }

        private static List<HashSet<string>> getVariableLists(List<Literal> preds)
        {
            List<HashSet<string>> previousVars = new List<HashSet<string>>();
            HashSet<String> variables = new HashSet<string>();
            foreach (var pred in preds)
            {
                HashSet<String> tempVar = new HashSet<string>();
                tempVar.UnionWith(variables);
                previousVars.Add(tempVar);
                foreach (var variable in pred.variables)
                {
                    variables.Add(variable);
                }
            }
            return previousVars;
        }

        private static void match(Literal literal, Dictionary<string, string> theta,  HashSet<ProgramNode> S, ref bool matchfound, Stack<Stack<string[]>> varsRecord)
        {
            Stack<String[]> variableStk = new Stack<String[]>();
            if (matchfound)
            {
                variableStk = firstMatch(literal, theta, S, ref matchfound);
                varsRecord.Push(variableStk);
            }
            else
            {
                variableStk = varsRecord.Peek();
                nextMatch(literal, theta, S, ref matchfound, variableStk);
            }
        }

        private static void nextMatch(Literal literal, Dictionary<string, string> theta,  HashSet<ProgramNode> S, ref bool matchfound, Stack<String[]> varStk)
        {
            Literal mockLit = new Literal();
            mockLit.id = literal.id;
            int index = 0;

            // Creates a mockLiteral with variables matching the given values already in theta or _
            mockLit.variables = new string[literal.variables.Length];
            literal.variables.CopyTo(mockLit.variables, 0);
            foreach (var variable in mockLit.variables)
            {
                if (theta.Keys.Contains(variable))
                    mockLit.variables[index] = theta[variable];
                else
                    mockLit.variables[index] = "_";
                index++;
            }

            var variables = varStk.Pop();
            //If there was a match
            if (variables != null)
            {
                if (mockLit.variables.Contains("_"))
                {
                    int varIndex = 0;
                    foreach (var variable in mockLit.variables)
                    {
                        if (variable == "_")
                        {
                            // Adds new free variable
                            theta.Add(literal.variables[varIndex], variables[varIndex]);
                        }
                        varIndex++;
                    }
                }
                matchfound = true;
            }
            else
            {
                matchfound = false;
            }
        }

        private static Stack<String[]> firstMatch(Literal literal, Dictionary<string, string> theta, HashSet<ProgramNode> S, ref bool matchfound)
        {
            // Create object to compare with.
            Stack<String[]> varStk = new Stack<string[]>();
            varStk.Push(null);
            Literal mockLit = new Literal();
            mockLit.id = literal.id;
            int index = 0;

            // Creates a mockLiteral with variables matching the given values already in theta or _
            mockLit.variables = new string[literal.variables.Length];
            literal.variables.CopyTo(mockLit.variables, 0);
            foreach (var variable in mockLit.variables)
            {
                if (theta.Keys.Contains(variable))
                    mockLit.variables[index] = theta[variable];
                else
                    mockLit.variables[index] = "_";
                index++;
            }

            foreach (var elem in S)
            {
                if (mockLit.id == elem.id)
                {
                    int counter = 0;
                    bool viableMatch = true;
                    //ProgramNode currRule = (ProgramNode) elem;
                    //TODO Probably the loop is wrong here.
                    foreach (var variable in elem.variables)
                    {
                        if (!(mockLit.variables[counter] == variable || mockLit.variables[counter] == "_"))
                        {
                            viableMatch = false;
                            break;
                        }
                        counter++;
                    }
                    if (viableMatch)                        
                        varStk.Push(elem.variables);
                    //SPLIT FROM LOOP
                    // By this time onwards we know we have a match.
                    // DONT WANT TO DO BELOW PART as part of the loop.                     
                }
            }
            // Pop first match on top of stack
            var variables = varStk.Pop();
            //If there was a match
            if (variables != null)
            {
                if (mockLit.variables.Contains("_"))
                {
                    int varIndex = 0;
                    foreach (var variable in mockLit.variables)
                    {
                        if (variable == "_")
                        {
                            // Adds new free variable
                            theta.Add(literal.variables[varIndex], variables[varIndex]);
                        }
                        varIndex++;
                    }
                }
                matchfound = true;
            }
            else
            {
                matchfound = false;
            }
            return varStk;
        }
    }
}
