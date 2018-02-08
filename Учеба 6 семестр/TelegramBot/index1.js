var clone = require('clone');
 
var a, b;
 
a = { foo: { bar: 'baz' } };  // initial value of a 
 
b = clone(a);                 // clone a -> b 
a.foo.bar = 'foo';            // change a 
 
console.log(a);               // show a 
console.log(b); 