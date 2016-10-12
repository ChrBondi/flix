var React = require('react');
var ReactDOM = require('react-dom');

var App = React.createClass({
    render: function () {
        return (
            <div className="app">
                <Nav/>
                <MembersBox/>
            </div>
        );
    }
});

var Nav = React.createClass({
    render: function () {
        return (
            <div className="nav">
                <div className="title">Flix Standard Library</div>
                <ul>
                    <li><a href="#">BigInt</a></li>
                    <li><a href="#">Float32</a></li>
                    <li><a href="#">Float64</a></li>
                    <li><a href="#">Int8</a></li>
                    <li><a href="#">Int16</a></li>
                    <li><a href="#">Int32</a></li>
                    <li><a href="#">Int64</a></li>
                </ul>
            </div>
        );
    }
});

var MembersBox = React.createClass({
    render: function () {
        return (
            <div className="members">
                <h1>Root</h1>

                <TypesBox/>
                <DefinitionList/>
                <RelationList/>
                <h2>Lattices</h2>
            </div>
        );
    }
});

var TypesBox = React.createClass({
    render: function () {
        return (
            <div className="types">
                <h2>Types</h2>
                ...
            </div>
        );
    }
});

var DefinitionList = React.createClass({
    render: function () {
        return (
            <div className="definitions">

                <h2>Definitions</h2>

                {getData().definitions.map(d =>
                    <DefinitionBox d={d}/>
                )}
            </div>
        );
    }
});

var DefinitionBox = React.createClass({
    render: function () {
        var name = this.props.d.name;
        var tparams = this.props.d.params.map(kv => <span>{kv.name}</span>);
        var fparams = this.props.d.params.map(kv => <span>{kv.name}</span>);
        var result = "todo";
        var comment = this.props.d.comment;
        return (
            <div className="definition">
                <div className="signature">
                    <span className="keyword">def</span>
                    <span className="name">{name}</span>
                    <span className="tparams">{tparams}</span>
                    <span className="fparams">{fparams}</span>
                    <span className="result">{result}</span>
                </div>
                <div className="comment">
                    {comment}
                </div>
            </div>
        );
    }
});


/**
 * Renders a list of relations.
 */
var RelationList = React.createClass({
    render: function () {
        return (
            <div className="Relations">
                <h2>Relations</h2>
                {getData().relations.map(r =>
                    <RelationBox r={r}/>
                )}
            </div>
        );
    }
});

/**
 * Renders a relation in a single box.
 */
var RelationBox = React.createClass({
    render: function () {
        var name = this.props.r.name;
        var attributes = this.props.r.attributes.map(
            attr => <span>{attr.name}: <span className="type">{attr.tpe}</span></span>
        );
        var comment = this.props.r.comment;
        return (
            <div className="relation">
                <div className="signature">
                    <span className="keyword">rel</span>
                    <span className="name">{name}</span>
                    <span className="attributes">({attributes})</span>
                </div>
                <div className="comment">{comment}</div>
            </div>
        );
    }
});

ReactDOM.render(
    <App />,
    document.getElementById('body')
);


function getData() {

    return {
        "definitions": [
            {
                "name": "minValue",
                "tparams": [],
                "params": [],
                "comment": "Returns the minimum number representable by an Int32."
            },
            {
                "name": "maxValue",
                "tparams": [],
                "params": [],
                "comment": "Returns the maximum number representable by an Int32."
            },
            {
                "name": "min",
                "tparams": [],
                "params": [{name: "x", tpe: "Int"}, {name: "y", tpe: "Int"}],
                "comment": "Returns the smaller of `x` and `y`."
            },
            {
                "name": "max",
                "tparams": [],
                "params": [],
                "comment": " Returns the larger of `x` and `y`."
            },
            {
                "name": "abs",
                "tparams": [],
                "params": [],
                "comment": "Returns the absolute value of `x`. If the absolute value exceeds maxValue(), -1 is returned."
            }
        ],
        "relations": [
            {
                name: "VarPointsTo",
                attributes: [
                    {name: "c", tpe: "Ctx"},
                    {name: "s", tpe: "Stm"},
                    {name: "x", tpe: "Var"},
                    {name: "o", tpe: "Obj"}
                ],
                comment: "Var `v` points-to object `o` at statement `s` in context `c`."
            }
        ],
        "lattices": []
    }

}
