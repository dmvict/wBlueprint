( function _Trait_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  if( !_.module.isIncluded( 'wProto' ) )
  {
    require( '../../abase/l2_blueprint/Include.s' );
  }

}

var _global = _global_;
var _ = _global_.wTools;

// --
// test
// --

function traitIs( test ) 
{
  test.case = 'instance of Definition, definitionGroup - trait';
  var src = new _.Definition( { ini : 1, definitionGroup : 'trait' } );
  var got = _.traitIs( src );
  test.identical( got, true );

  // test.case = 'callable trait'; // Dmytro : uncomment when callable routine will be fixed
  // var src = _.trait.callable( ( e ) => e );
  // var got = _.traitIs( src );
  // test.identical( got, true );
  //
  // test.case = 'callable trait';
  // var src = _.trait.callable( { callback : ( e ) => e } );
  // var got = _.traitIs( src );
  // test.identical( got, true );

  test.case = 'typed trait';
  var src = _.trait.typed();
  var got = _.traitIs( src );
  test.identical( got, true );

  test.case = 'extendable trait';
  var src = _.trait.extendable();
  var got = _.traitIs( src );
  test.identical( got, true );

  test.case = 'prototype trait';
  var Blueprint = _.blueprint( { field1 : ( e ) => 'x' + e } );
  var src = _.trait.prototype( { value : Blueprint } );
  var got = _.traitIs( src );
  test.identical( got, true );
}

// --
// declare
// --

var Self =
{

  name : 'Tools.base.l2.Blueprint.trait',
  silencing : 1,

  tests :
  {
    traitIs, // Dmytro : the second part of routine in module wTools
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
