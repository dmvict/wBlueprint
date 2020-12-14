( function _Accessor_s_() {

'use strict';

let Self = _global_.wTools;
let _global = _global_;
let _ = _global_.wTools;

/**
 * @summary Collection of routines for declaring accessors
 * @namespace wTools.accessor
 * @extends Tools
 * @module Tools/base/Proto
 */

// --
// fields
// --

/**
 * Accessor defaults
 * @typedef {Object} AccessorDefaults
 * @property {Boolean} [ strict=1 ]
 * @property {Boolean} [ preservingValue=1 ]
 * @property {Boolean} [ prime=1 ]
 * @property {String} [ combining=null ]
 * @property {Boolean} [ writable=true ]
 * @property {Boolean} [ readOnlyProduct=0 ]
 * @property {Boolean} [ enumerable=1 ]
 * @property {Boolean} [ configurable=0 ]
 * @property {Function} [ getter=null ]
 * @property {Function} [ graber=null ]
 * @property {Function} [ setter=null ]
 * @property {Function} [ suite=null ]
 * @namespace Tools.accessor
 **/

let Combining = [ 'rewrite', 'supplement', 'apppend', 'prepend' ];
let StoringStrategy = [ 'symbol', 'underscore' ];
let AmethodTypes = [ 'grab', 'get', 'put', 'set', 'move' ];

let AmethodTypesMap =
{
  grab : null,
  get : null,
  put : null,
  set : null,
  move : null,
}

let AccessorFieldsMap =
{
  ... AmethodTypesMap,
  suite : null,
  val : _.nothing,
}

let AccessorDefaults =
{

  ... AccessorFieldsMap,

  preservingValue : null,
  prime : null,
  combining : null,
  addingMethods : null,
  enumerable : null,
  configurable : null,
  writable : null,
  storingStrategy : null,
  storingIniting : null,

  strict : true, /* zzz : deprecate */
  // storingStrategy : 'symbol', /* yyy */
  // readOnly : 0, /* yyy : use writable instead */
  // readOnlyProduct : 0,

}

let AccessorPreferences =
{

  ... AccessorFieldsMap,
  suite : null,

  preservingValue : true,
  prime : null,
  combining : null,
  addingMethods : false,
  enumerable : true,
  configurable : true,
  writable : null,
  storingStrategy : 'symbol',
  storingIniting : true,

  strict : true,
  // writable : 1,
  // readOnlyProduct : 0,

}

// --
// getter / setter generator
// --

function _propertyGetterSetterNames( propertyName )
{
  let result = Object.create( null );

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( propertyName ) );

  result.grab = '_' + propertyName + 'Grab';
  result.get = '_' + propertyName + 'Get';
  result.put = '_' + propertyName + 'Put';
  result.set = '_' + propertyName + 'Set';
  result.move = '_' + propertyName + 'Move';

  /* zzz : use it? */

  return result;
}

//

function _optionsNormalize( o )
{

  _.assert( arguments.length === 1 );

  optionNormalize( 'grab' );
  optionNormalize( 'get' );
  optionNormalize( 'put' );
  optionNormalize( 'set' );

  function optionNormalize( n1 )
  {
    if( _.boolLike( o[ n1 ] ) )
    o[ n1 ] = !!o[ n1 ];
  }

}

//

function _asuiteForm_head( routine, args )
{
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );
  let o = _.routineOptions( routine, args );
  return o;
}

function _asuiteForm_body( o )
{

  _.assert( arguments.length === 1 );
  _.assert( o.methods === null || !_.primitiveIs( o.methods ) );
  _.assert( _.strIs( o.name ) || _.symbolIs( o.name ) );
  _.assert( _.mapIs( o.asuite ) );
  _.assert( o.writable === null || _.boolIs( o.writable ) );
  _.assertMapHasOnly( o.asuite, _.accessor.AmethodTypesMap );
  _.assertRoutineOptions( _asuiteForm_body, o );

  let propName;
  if( _.symbolIs( o.name ) )
  {
    propName = Symbol.keyFor( o.name );
  }
  else
  {
    propName = o.name;
  }

  if( o.suite )
  _.assertMapHasOnly( o.suite, _.accessor.AmethodTypes );

  for( let k in o.asuite, _.accessor.AmethodTypesMap )
  methodNormalize( k );

  _.assert( o.writable !== false || !o.asuite.set );

  /* grab */

  if( o.asuite.grab === null || o.asuite.grab === true )
  {
    if( o.asuite.move )
    o.asuite.grab = _.accessor._amethodFromMove( propName, 'grab', o.asuite.move );
    else if( _.routineIs( o.asuite.get ) )
    o.asuite.grab = o.asuite.get;
    else
    o.asuite.grab = _.accessor._amethodFunctor( propName, 'grab', o.storingStrategy );
  }

  /* get */

  if( o.asuite.get === null || o.asuite.get === true )
  {
    if( o.asuite.move )
    o.asuite.get = _.accessor._amethodFromMove( propName, 'get', o.asuite.move );
    else if( _.routineIs( o.asuite.grab ) )
    o.asuite.get = o.asuite.grab;
    else
    o.asuite.get = _.accessor._amethodFunctor( propName, 'get', o.storingStrategy );
  }

  /* put */

  if( o.asuite.put === null || o.asuite.put === true )
  {
    if( o.asuite.move )
    o.asuite.put = _.accessor._amethodFromMove( propName, 'put', o.asuite.move );
    else if( _.routineIs( o.asuite.set ) )
    o.asuite.put = o.asuite.set;
    else
    o.asuite.put = _.accessor._amethodFunctor( propName, 'put', o.storingStrategy );
  }

  /* set */

  if( o.asuite.set === null || o.asuite.set === true )
  {
    if( o.writable === false )
    {
      _.assert( o.asuite.set === null );
      o.asuite.set = false;
    }
    else if( o.asuite.move )
    o.asuite.set = _.accessor._amethodFromMove( propName, 'set', o.asuite.move );
    else if( _.routineIs( o.asuite.put ) )
    o.asuite.set = o.asuite.put;
    else if( o.asuite.put !== false || o.asuite.set )
    o.asuite.set = _.accessor._amethodFunctor( propName, 'set', o.storingStrategy );
    else
    o.asuite.set = false;
  }

  /* move */

  if( o.asuite.move === true )
  {
    o.asuite.move = function move( it )
    {
      _.assert( 0, 'not tested' ); /* zzz */
      debugger;
      return it.src;
    }
  }
  else if( !o.asuite.move )
  {
    o.asuite.move = false;
    _.assert( o.asuite.move === false );
  }

  // /* readOnlyProduct */
  //
  // if( o.readOnlyProduct && o.asuite.get )
  // {
  //   let get = o.asuite.get;
  //   o.asuite.get = function get()
  //   {
  //     debugger;
  //     let o.asuite = get.apply( this, arguments );
  //     if( !_.primitiveIs( o.asuite ) )
  //     o.asuite = _.proxyReadOnly( o.asuite );
  //     return o.asuite;
  //   }
  // }

  /* validation */

  if( Config.debug )
  {
    for( let k in AmethodTypesMap )
    _.assert
    (
      _.definitionIs( o.asuite[ k ] ) || _.routineIs( o.asuite[ k ] ) || o.asuite[ k ] === false,
      () => `Field "${propName}" is not read only, but setter not found ${_.toStrShort( o.methods )}`
    );
  }

  return o.asuite;

  /* */

  function methodNormalize( name )
  {
    let capitalName = _.strCapitalize( name );
    _.assert( o.asuite[ name ] === null || _.boolLike( o.asuite[ name ] ) || _.routineIs( o.asuite[ name ] ) || _.definitionIs( o.asuite[ name ] ) );

    if( o.suite && _.boolLikeFalse( o.suite[ name ] ) )
    {
      _.assert( !o.asuite[ name ] );
      o.asuite[ name ] = false;
      o.suite[ name ] = false;
    }
    else if( _.boolLikeFalse( o.asuite[ name ] ) )
    {
      o.asuite[ name ] = false;
    }
    else if( _.boolLikeTrue( o.asuite[ name ] ) )
    {
      o.asuite[ name ] = true;
    }

    if( o.asuite[ name ] === null || o.asuite[ name ] === true )
    {
      if( _.routineIs( o.asuite[ name ] ) || _.definitionIs( o.asuite[ name ] ) )
      o.asuite[ name ] = o.asuite[ name ];
      else if( o.suite && ( _.routineIs( o.suite[ name ] ) || _.definitionIs( o.suite[ name ] ) ) )
      o.asuite[ name ] = o.suite[ name ];
      else if( o.methods && o.methods[ '' + propName + capitalName ] )
      o.asuite[ name ] = o.methods[ propName + capitalName ];
      else if( o.methods && o.methods[ '_' + propName + capitalName ] )
      o.asuite[ name ] = o.methods[ '_' + propName + capitalName ];
    }
  }

  /* */

}

_asuiteForm_body.defaults =
{
  suite : null,
  asuite : null,
  methods : null,
  writable : null,
  storingStrategy : 'symbol',
  name : null,
}

let _asuiteForm = _.routineUnite( _asuiteForm_head, _asuiteForm_body );

//

function _asuiteUnfunct( o )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o.asuite ) );
  _.assertRoutineOptions( _asuiteUnfunct, arguments );

  resultUnfunct( 'grab' );
  resultUnfunct( 'get' );
  resultUnfunct( 'put' );
  resultUnfunct( 'set' );
  resultUnfunct( 'move' );

  return o.asuite;

  /* */

  function resultUnfunct( kind )
  {
    _.assert( _.primitiveIs( kind ) );
    if( !o.asuite[ kind ] )
    return;
    let amethod = o.asuite[ kind ];
    let r = _.accessor._amethodUnfunct
    ({
      amethod,
      kind,
      accessor : o.accessor,
      withDefinition : o.withDefinition,
      withFunctor : o.withFunctor,
    });
    o.asuite[ kind ] = r;
    return r;
  }

}

var defaults = _asuiteUnfunct.defaults =
{
  accessor : null,
  asuite : null,
  withDefinition : false,
  withFunctor : true,
}

//

function _amethodUnfunct( o )
{

  _.assert( arguments.length === 1 );
  if( !o.amethod )
  return o.amethod;

  _.assert( !_.routineIs( o.amethod ) || !o.amethod.identity || _.mapIs( o.amethod.identity ) );

  if( o.withFunctor && o.amethod.identity && o.amethod.identity.functor )
  {
    functorUnfunct();
    if( o.kind === 'suite' && o.withDefinition && _.definitionIs( o.amethod ) )
    definitionUnfunct();
  }
  else if( o.kind === 'suite' && o.withDefinition && _.definitionIs( o.amethod ) )
  {
    definitionUnfunct();
    if( o.withFunctor && o.amethod.identity && o.amethod.identity.functor )
    functorUnfunct();
  }

  _.assert( o.amethod !== undefined );
  return o.amethod;

  function functorUnfunct()
  {
    let o2 = Object.create( null );
    if( o.amethod.defaults )
    {
      if( o.amethod.defaults.propName !== undefined )
      o2.propName = o.accessor.name;
      if( o.amethod.defaults.accessor !== undefined )
      o2.accessor = o.accessor;
      if( o.amethod.defaults.accessorKind !== undefined )
      o2.accessorKind = o.kind;
    }
    o.amethod = o.amethod( o2 );
  }

  function definitionUnfunct()
  {
    _.assert( _.routineIs( o.amethod.asAccessorSuite ) );
    o.amethod = o.amethod.asAccessorSuite( o );
    _.assert( o.amethod !== undefined );
  }

}

_amethodUnfunct.defaults =
{
  amethod : null,
  accessor : null,
  kind : null,
  withDefinition : false,
  withFunctor : true,
}

//

function _objectMethodsNamesGet( o )
{

  _.routineOptions( _objectMethodsNamesGet, o );

  if( o.anames === null )
  o.anames = Object.create( null );

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o.asuite ) );
  _.assert( _.strIs( o.name ) );
  _.assert( !!o.object );

  for( let t = 0 ; t < _.accessor.AmethodTypes.length ; t++ )
  {
    let type = _.accessor.AmethodTypes[ t ];
    if( o.asuite[ type ] && !o.anames[ type ] )
    {
      let type2 = _.strCapitalize( type );
      if( o.object[ o.name + type2 ] === o.asuite[ type ] )
      o.anames[ type ] = o.name + type2;
      else if( o.object[ '_' + o.name + type2 ] === o.asuite[ type ] )
      o.anames[ type ] = '_' + o.name + type2;
      else
      o.anames[ type ] = o.name + type2;
    }
  }

  return o.anames;
}

_objectMethodsNamesGet.defaults =
{
  object : null,
  asuite : null,
  anames : null,
  name : null,
}

//

function _objectMethodsGet( object, propertyName )
{
  let result = Object.create( null );

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.objectIs( object ) );
  _.assert( _.strIs( propertyName ) );

  result.grabName = object[ propertyName + 'Grab' ] ? propertyName + 'Grab' : '_' + propertyName + 'Grab';
  result.getName = object[ propertyName + 'Get' ] ? propertyName + 'Get' : '_' + propertyName + 'Get';
  result.putName = object[ propertyName + 'Put' ] ? propertyName + 'Put' : '_' + propertyName + 'Put';
  result.setName = object[ propertyName + 'Set' ] ? propertyName + 'Set' : '_' + propertyName + 'Set';
  result.moveName = object[ propertyName + 'Move' ] ? propertyName + 'Move' : '_' + propertyName + 'Move';

  result.grab = object[ result.grabName ];
  result.get = object[ result.getName ];
  result.set = object[ result.setName ];
  result.put = object[ result.putName ];
  result.move = object[ result.moveName ];

  return result;
}

//

function _objectMethodsValidate( o )
{

  if( !Config.debug )
  return true;

  _.assert( _.strIs( o.name ) || _.symbolIs( o.name ) );
  _.assert( !!o.object );
  _.routineOptions( _objectMethodsValidate, o );

  let name = _.symbolIs( o.name ) ? Symbol.keyFor( o.name ) : o.name;
  let AmethodTypes = _.accessor.AmethodTypes;

  for( let t = 0 ; t < AmethodTypes.length ; t++ )
  {
    let type = AmethodTypes[ t ];
    if( !o.asuite[ type ] )
    {
      let name1 = name + _.strCapitalize( type );
      let name2 = '_' + name + _.strCapitalize( type );
      _.assert( !( name1 in o.object ), `Object should not have method ${name1}, if accessor has it disabled` );
      _.assert( !( name2 in o.object ), `Object should not have method ${name2}, if accessor has it disabled` );
    }
  }

  return true;
}

_objectMethodsValidate.defaults =
{
  object : null,
  asuite : null,
  name : null,
}

//

function _objectMethodMoveGet( srcInstance, name )
{
  _.assert( arguments.length === 2 );
  _.assert( _.strIs( name ) );

  if( !_.instanceIs( srcInstance ) )
  return null;

  if( srcInstance[ name + 'Move' ] )
  return srcInstance[ name + 'Move' ];
  else if( srcInstance[ '_' + name + 'Move' ] )
  return srcInstance[ '_' + name + 'Move' ];

  return null;
}

//

function _amethodFunctor( propName, amethodType, storingStrategy )
{
  let fieldSymbol;

  if( storingStrategy === 'symbol' )
  {
    fieldSymbol = Symbol.for( propName );
    if( amethodType === 'grab' )
    return grabWithSymbol;
    else if( amethodType === 'get' )
    return getWithSymbol;
    else if( amethodType === 'put' )
    return putWithSymbol;
    else if( amethodType === 'set' )
    return setWithSymbol;
    else _.assert( 0 );
  }
  else if( storingStrategy === 'underscore' )
  {
    if( amethodType === 'grab' )
    return grabWithUnderscore;
    else if( amethodType === 'get' )
    return getWithUnderscore;
    else if( amethodType === 'put' )
    return putWithUnderscore;
    else if( amethodType === 'set' )
    return setWithUnderscore;
    else _.assert( 0 );
  }
  else _.assert( 0 );

  /* */

  function grabWithSymbol()
  {
    return this[ fieldSymbol ];
  }

  function getWithSymbol()
  {
    return this[ fieldSymbol ];
  }

  function putWithSymbol( src )
  {
    this[ fieldSymbol ] = src;
    return src;
  }

  function setWithSymbol( src )
  {
    this[ fieldSymbol ] = src;
    return src;
  }

  /* */

  function grabWithUnderscore()
  {
    return this._[ propName ];
  }

  function getWithUnderscore()
  {
    return this._[ propName ];
  }

  function putWithUnderscore( src )
  {
    this._[ propName ] = src;
    return src;
  }

  function setWithUnderscore( src )
  {
    this._[ propName ] = src;
    return src;
  }

  /* */

}

//

function _amethodFromMove( propName, amethodType, move )
{

  if( amethodType === 'grab' )
  return grab;
  else if( amethodType === 'get' )
  return get;
  else if( amethodType === 'put' )
  return put;
  else if( amethodType === 'set' )
  return set;
  else _.assert( 0 );

  /* */

  function grab()
  {
    let it = _.accessor._moveItMake
    ({
      srcInstance : this,
      instanceKey : propName,
      accessorKind : 'grab',
    });
    move.call( this, it );
    return it.value;
  }

  function get()
  {
    let it = _.accessor._moveItMake
    ({
      srcInstance : this,
      instanceKey : propName,
      accessorKind : 'get',
    });
    move.call( this, it );
    return it.value;
  }

  function put( src )
  {
    let it = _.accessor._moveItMake
    ({
      dstInstance : this,
      instanceKey : propName,
      value : src,
      accessorKind : 'put',
    });
    move.call( this, it );
    return it.value;
  }

  function set( src )
  {
    let it = _.accessor._moveItMake
    ({
      dstInstance : this,
      instanceKey : propName,
      value : src,
      accessorKind : 'set',
    });
    move.call( this, it );
    return it.value;
  }

}

//

function _moveItMake( o )
{
  return _.routineOptions( _moveItMake, arguments );
}

_moveItMake.defaults =
{
  dstInstance : null,
  srcInstance : null,
  instanceKey : null,
  srcContainer : null,
  dstContainer : null,
  containerKey : null,
  accessorKind : null,
  value : null,
}

//

// function _objectPreserveValue( o )
// {
//
//   _.assertMapHasAll( o, _objectPreserveValue.defaults );
//
//   if( Object.hasOwnProperty.call( o.object, o.name ) )
//   {
//     o.val = o.object[ o.name ];
//     _.accessor._objectSetValue( o );
//   }
//
// }
//
// _objectPreserveValue.defaults =
// {
//   object : null,
//   name : null,
//   asuite : null,
// }

//

function _objectSetValue( o )
{

  _.assertMapHasAll( o, _objectSetValue.defaults );

  if( o.asuite.put )
  {
    o.asuite.put.call( o.object, o.val );
  }
  else if( o.asuite.set )
  {
    o.asuite.set.call( o.object, o.val );
  }
  else
  {
    let put = _.accessor._amethodFunctor( o.name, 'put', o.storingStrategy );
    put.call( o.object, o.val );
  }

}

_objectSetValue.defaults =
{
  object : null,
  asuite : null,
  storingStrategy : null,
  name : null,
  val : null,
}

//

function _objectAddMethods( o )
{

  _.assertRoutineOptions( _objectAddMethods, o );

  for( let n in o.asuite )
  {
    if( o.asuite[ n ] )
    Object.defineProperty( o.object, o.anames[ n ],
    {
      value : o.asuite[ n ],
      enumerable : false,
      writable : true,
      configurable : true,
    });
  }

}

_objectAddMethods.defaults =
{
  object : null,
  asuite : null,
  anames : null,
}

//

function _objectInitStorage( object, storingStrategy )
{

  if( storingStrategy === 'underscore' )
  {
    if( !Object.hasOwnProperty.call( object, '_' ) )
    Object.defineProperty( object, '_',
    {
      value : Object.create( null ),
      enumerable : false,
      writable : false,
      configurable : false,
    });
  }

}

// --
// declare
// --

/**
 * Registers provided accessor.
 * Writes accessor's descriptor into accessors map of the prototype ( o.proto ).
 * Supports several combining methods: `rewrite`, `supplement`, `append`.
 *  * Adds diagnostic information to descriptor if running in debug mode.
 * @param {Object} o - options map
 * @param {String} o.name - accessor's name
 * @param {Object} o.proto - target prototype object
 * @param {String} o.declaratorName
 * @param {Array} o.declaratorArgs
 * @param {String} o.declaratorKind
 * @param {String} o.combining - combining method
 * @private
 * @function _register
 * @namespace Tools.accessor
 */

function _register( o )
{

  _.routineOptions( _register, arguments );
  _.assert( _.strDefined( o.declaratorName ) );
  _.assert( _.arrayIs( o.declaratorArgs ) );

  return descriptor;
}

_register.defaults =
{
  name : null,
  proto : null,
  declaratorName : null,
  declaratorArgs : null,
  declaratorKind : null,
  combining : 0,
}

//

function declareSingle_head( routine, args )
{

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );
  let o = _.routineOptions( routine, args );
  _.assert( !_.primitiveIs( o.object ), 'Expects object as argument but got', o.object );
  _.assert( _.strIs( o.name ) || _.symbolIs( o.name ) );
  _.assert( _.longHas( [ null, 0, false, 'rewrite', 'supplement' ], o.combining ), 'not tested' );

  if( _.boolLike( o.writable ) )
  o.writable = !!o.writable;

  if( _.boolLikeTrue( o.suite ) )
  o.suite = Object.create( null );

  return o;
}

function declareSingle_body( o )
{

  if( _.boolLike( o.writable ) )
  o.writable = !!o.writable;

  _.assertRoutineOptions( declareSingle_body, arguments );
  _.assert( arguments.length === 1 );
  _.assert( _.boolIs( o.writable ) || o.writable === null );

  _.accessor._optionsNormalize( o );

  let propName;
  if( _.symbolIs( o.name ) )
  {
    propName = Symbol.keyFor( o.name );
  }
  else
  {
    propName = o.name;
  }

  /* */

  if( !needed() )
  return false;

  defaultsApply();

  /* */

  o.suite = _.accessor._amethodUnfunct
  ({
    amethod : o.suite,
    accessor : o,
    kind : 'suite',
    withDefinition : true,
    withFunctor : true,
  });

  o.asuite = _.accessor._asuiteForm.body
  ({
    name : o.name,
    methods : o.methods,
    suite : o.suite,
    writable : o.writable,
    storingStrategy : o.storingStrategy,
    asuite :
    {
      grab : o.grab,
      get : o.get,
      put : o.put,
      set : o.set,
      move : o.move,
    },
  });

  _.accessor._asuiteUnfunct
  ({
    accessor : o,
    asuite : o.asuite,
    withDefinition : false,
    withFunctor : true,
  });

  if( o.writable === null )
  o.writable = !!o.asuite.set;
  _.assert( _.boolLike( o.writable ) );

  let anames;
  if( o.prime || o.addingMethods )
  anames = _.accessor._objectMethodsNamesGet
  ({
    object : o.object,
    asuite : o.asuite,
    name : o.name,
  })

  /* */

  if( o.prime )
  register();

  /* addingMethods */

  if( o.addingMethods )
  _.accessor._objectAddMethods
  ({
    object : o.object,
    asuite : o.asuite,
    anames,
  });

  /* init storage */

  if( o.storingIniting )
  _.accessor._objectInitStorage( o.object, o.storingStrategy );
  // if( o.storingStrategy === 'underscore' )
  // {
  //   if( !o.object[ '_' ] )
  //   Object.defineProperty( o.object, '_',
  //   {
  //     value : Object.create( null ),
  //     enumerable : false,
  //     writable : false,
  //     configurable : false,
  //   });
  // }

  /* cache value */

  if( _.definitionIs( o.asuite.get ) )
  {
    if( o.val === _.nothing )
    o.val = _.definition.toVal( o.asuite.get );
    o.asuite.get = null;
  }

  if( o.val === _.nothing )
  if( o.preservingValue && Object.hasOwnProperty.call( o.object, o.name ) )
  o.val = o.object[ o.name ];

  // if( o.val !== _.nothing )
  // {
  //   _.accessor._objectSetValue
  //   ({
  //     object : o.object,
  //     asuite : o.asuite,
  //     storingStrategy : o.storingStrategy,
  //     name : o.name,
  //     val : o.val,
  //   });
  // }
  // else if( o.preservingValue )
  // {
  //   if( Object.hasOwnProperty.call( o.object, o.name ) )
  //   _.accessor._objectSetValue
  //   ({
  //     object : o.object,
  //     asuite : o.asuite,
  //     storingStrategy : o.storingStrategy,
  //     name : o.name,
  //     val : o.object[ o.name ],
  //   });
  // }

  /* define accessor */

  // _.assert( o.asuite.get === false || _.routineIs( o.asuite.get ) || _.definitionIs( o.asuite.get ) ); /* yyy */
  // _.assert( o.asuite.set === false || _.routineIs( o.asuite.set ) );

  _.property.declare.body
  ({
    object : o.object,
    name : o.name,
    enumerable : !!o.enumerable,
    configurable : !!o.configurable,
    writable : !!o.writable,
    get : o.asuite.get,
    set : o.asuite.set,
    val : o.asuite.get === null ? o.val : _.nothing,
  });

  /* set value */

  if( o.val !== _.nothing && o.asuite.get !== null )
  _.accessor._objectSetValue
  ({
    object : o.object,
    asuite : o.asuite,
    storingStrategy : o.storingStrategy,
    name : o.name,
    val : o.val,
  });

  /* validate */

  if( Config.debug )
  validate();

  return o;

  /* - */

  function needed()
  {
    let propertyDescriptor = _.prototype.propertyDescriptorActiveGet( o.object, o.name );
    if( propertyDescriptor.descriptor )
    {

      _.assert
      (
        _.strIs( o.combining ), () =>
          `Option::overriding of property ${o.name}`
        + ` supposed to be any of ${_.accessor.Combining }`
        + ` but it is ${o.combining}`
      );
      _.assert( o.combining === 'rewrite' || o.combining === 'append' || o.combining === 'supplement', 'not implemented' );

      if( o.combining === 'supplement' )
      return false;

      _.assert( propertyDescriptor.object !== o.object, () => `Attempt to redefine own accessor "${o.name}" of ${_.toStrShort( o.object )}` );

    }
    return true;
  }

  /* */

  function validate()
  {
    _.accessor._objectMethodsValidate({ object : o.object, name : o.name, asuite : o.asuite });
  }

  /* */

  function defaultsApply()
  {

    if( o.prime === null )
    o.prime = !!_.workpiece && _.workpiece.prototypeIsStandard( o.object );

    for( let k in o )
    {
      if( o[ k ] === null && _.accessor.AccessorPreferences[ k ] !== undefined )
      o[ k ] = _.accessor.AccessorPreferences[ k ];
    }

    _.assert( _.boolLike( o.prime ) );
    _.assert( _.boolLike( o.configurable ) );
    _.assert( _.boolLike( o.enumerable ) );
    _.assert( _.boolLike( o.addingMethods ) );
    _.assert( _.boolLike( o.preservingValue ) );

  }

  /* */

  function register()
  {

    let o2 = _.mapExtend( null, o );
    o2.names = o.name;
    o2.methods = Object.create( null );
    o2.object = null;
    delete o2.name;
    delete o2.asuite;

    for( let k in o.asuite )
    if( o.asuite[ k ] )
    o2.methods[ anames[ k ] ] = o.asuite[ k ];

    _.accessor._register
    ({
      proto : o.object,
      name : o.name,
      declaratorName : 'accessor',
      declaratorArgs : [ o2 ],
      combining : o.combining,
    });

  }

  /* */

}

var defaults = declareSingle_body.defaults =
{
  ... AccessorDefaults,
  name : null,
  object : null,
  methods : null,
}

let declareSingle = _.routineUnite( declareSingle_head, declareSingle_body );

//

/**
 * Accessor options
 * @typedef {Object} AccessorOptions
 * @property {Object} [ object=null ] - source object wich properties will get getter/setter defined.
 * @property {Object} [ names=null ] - map that that contains names of fields for wich function defines setter/getter.
 * Function uses values( rawName ) of object( o.names ) properties to check if fields of( o.object ) have setter/getter.
 * Example : if( rawName ) is 'a', function searchs for '_aSet' or 'aSet' and same for getter.
 * @property {Object} [ methods=null ] - object where function searchs for existing setter/getter of property.
 * @property {Array} [ message=null ] - setter/getter prints this message when called.
 * @property {Boolean} [ strict=true ] - makes object field private if no getter defined but object must have own constructor.
 * @property {Boolean} [ enumerable=true ] - sets property descriptor enumerable option.
 * @property {Boolean} [ preservingValue=true ] - saves values of existing object properties.
 * @property {Boolean} [ prime=true ]
 * @property {String} [ combining=null ]
 * @property {Boolean} [ writable=true ] - if false function doesn't define setter to property.
 * @property {Boolean} [ configurable=false ]
 * @property {Function} [ get=null ]
 * @property {Function} [ set=null ]
 * @property {Function} [ suite=null ]
 *
 * @namespace Tools.accessor
 **/

/**
 * Defines set/get functions on source object( o.object ) properties if they dont have them.
 * If property specified by( o.names ) doesn't exist on source( o.object ) function creates it.
 * If ( o.object.constructor.prototype ) has property with getter defined function forbids set/get access
 * to object( o.object ) property. Field can be accessed by use of Symbol.for( rawName ) function,
 * where( rawName ) is value of property from( o.names ) object.
 *
 * Can be called in three ways:
 * - First by passing all options in one object( o );
 * - Second by passing ( object ) and ( names ) options;
 * - Third by passing ( object ), ( names ) and ( message ) option as third parameter.
 *
 * @param {Object} o - options {@link module:Tools/base/Proto.wTools.accessor~AccessorOptions}.
 *
 * @example
 * let Self = ClassName;
function ClassName( o ) { };
 * _.accessor.declare( Self, { a : 'a' }, 'set/get call' )
 * Self.a = 1; // set/get call
 * Self.a;
 * // returns
 * // set/get call
 * // 1
 *
 * @throws {exception} If( o.object ) is not a Object.
 * @throws {exception} If( o.names ) is not a Object.
 * @throws {exception} If( o.methods ) is not a Object.
 * @throws {exception} If( o.message ) is not a Array.
 * @throws {exception} If( o ) is extented by unknown property.
 * @throws {exception} If( o.strict ) is true and object doesn't have own constructor.
 * @throws {exception} If( o.writable ) is false and property has own setter.
 * @function declare
 * @namespace Tools.accessor
 */

function declareMultiple_head( routine, args )
{
  let o;

  _.assert( arguments.length === 2 );

  if( args.length === 1 )
  {
    o = args[ 0 ];
  }
  else
  {
    o = Object.create( null );
    o.object = args[ 0 ];
    o.names = args[ 1 ];
    _.assert( args.length >= 2 );
  }

  if( args.length > 2 )
  {
    _.assert( o.messages === null || o.messages === undefined );
    o.message = _.longSlice( args, 2 );
  }

  if( _.strIs( o.names ) )
  o.names = { [ o.names ] : o.names }

  _.routineOptions( routine, o );

  // if( o.writable === null )
  // o.writable = true;

  if( _.boolLike( o.writable ) )
  o.writable = !!o.writable;

  _.assert( !_.primitiveIs( o.object ), 'Expects object as argument but got', o.object );
  _.assert( _.objectIs( o.names ) || _.arrayIs( o.names ), 'Expects object names as argument but got', o.names );

  return o;
}

function declareMultiple_body( o )
{

  _.assertRoutineOptions( declareMultiple_body, arguments );

  if( _.arrayLike( o.object ) )
  {
    _.each( o.object, ( object ) =>
    {
      let o2 = _.mapExtend( null, o );
      o2.object = object;
      declareMultiple_body( o2 );
    });
    return o.object;
  }

  if( !o.methods )
  o.methods = o.object;

  /* verification */

  _.assert( !_.primitiveIs( o.methods ) );
  _.assert( !_.primitiveIs( o.object ), () => 'Expects object {-object-}, but got ' + _.toStrShort( o.object ) );
  _.assert( _.objectIs( o.names ), () => 'Expects object {-names-}, but got ' + _.toStrShort( o.names ) );

  /* */

  let result = Object.create( null );
  for( let name in o.names )
  result[ name ] = declare( name, o.names[ name ] );

  let names2 = Object.getOwnPropertySymbols( o.names );
  for( let n = 0 ; n < names2.length ; n++ )
  result[ names2[ n ] ] = declare( names2[ n ], o.names[ names2[ n ] ],  );

  return result;

  /* */

  function declare( name, extension )
  {
    let o2 = Object.assign( Object.create( null ), o );

    _.assert( !_.routineIs( extension ) || !extension.identity || _.mapIs( extension.identity ) );

    if( _.mapIs( extension ) )
    {
      _.assertMapHasOnly( extension, _.accessor.AccessorDefaults );
      _.mapExtend( o2, extension );
      _.assert( !!o2.object );
    }
    else if( _.definitionIs( extension ) )
    {
      o2.suite = extension;
    }
    // yyy
    // else if( _.definitionIs( extension ) && extension.subKind === 'constant' )
    // {
    //   _.mapExtend( o2, { get : extension, set : false, put : false } );
    // }
    // else if( _.routineIs( extension ) && extension.identity && _.longHas( extension.identity, 'functor' ) )
    else if( _.routineIs( extension ) && extension.identity && extension.identity.functor )
    {
      _.mapExtend( o2, { suite : extension } );
    }
    else _.assert( name === extension, `Unexpected type ${_.strType( extension )}` );

    o2.name = name;
    delete o2.names;

    return _.accessor.declareSingle.body( o2 );
  }

}

var defaults = declareMultiple_body.defaults = _.mapExtend( null, declareSingle.defaults );
defaults.names = null;
delete defaults.name;

let declareMultiple = _.routineUnite( declareMultiple_head, declareMultiple_body );

//

/**
 * @summary Declares forbid accessor.
 * @description
 * Forbid accessor throws an Error when user tries to get value of the property.
 * @param {Object} o - options {@link module:Tools/base/Proto.wTools.accessor~AccessorOptions}.
 *
 * @example
 * let Self = ClassName;
function ClassName( o ) { };
 * _.accessor.forbid( Self, { a : 'a' } )
 * Self.a; // throw an Error
 *
 * @function forbid
 * @namespace Tools.accessor
 */

function forbid_body( o )
{

  _.assertRoutineOptions( forbid_body, arguments );

  if( !o.methods )
  o.methods = Object.create( null );

  if( _.arrayLike( o.object ) )
  {
    debugger;
    _.each( o.object, ( object ) =>
    {
      let o2 = _.mapExtend( null, o );
      o2.object = object;
      forbid_body( o2 );
    });
    debugger;
    return o.object;
  }

  if( _.objectIs( o.names ) )
  o.names = _.mapExtend( null, o.names );

  if( o.prime === null )
  o.prime = !!_.workpiece && _.workpiece.prototypeIsStandard( o.object );

  /* verification */

  _.assert( !_.primitiveIs( o.object ), () => 'Expects object {-o.object-} but got ' + _.toStrShort( o.object ) );
  _.assert( _.objectIs( o.names ) || _.arrayIs( o.names ), () => 'Expects object {-o.names-} as argument but got ' + _.toStrShort( o.names ) );

  /* message */

  let _constructor = o.object.constructor || null;
  _.assert( _.routineIs( _constructor ) || _constructor === null );
  if( !o.protoName )
  o.protoName = ( _constructor ? ( _constructor.name || _constructor._name || '' ) : '' ) + '.';
  if( !o.message )
  o.message = 'is deprecated';
  else
  o.message = _.arrayIs( o.message ) ? o.message.join( ' : ' ) : o.message;

  /* property */

  if( _.objectIs( o.names ) )
  {
    let result = Object.create( null );

    for( let n in o.names )
    {
      let name = o.names[ n ];
      let o2 = _.mapExtend( null, o );
      o2.propName = name;
      _.assert( n === name, () => 'Key and value should be the same, but ' + _.strQuote( n ) + ' and ' + _.strQuote( name ) + ' are not' );
      let declared = _.accessor._forbidSingle( o2 );
      if( declared )
      result[ name ] = declared;
      else
      delete o.names[ name ];
    }

    return result;
  }
  else
  {
    let result = [];
    let namesArray = o.names;

    o.names = Object.create( null );
    for( let n = 0 ; n < namesArray.length ; n++ )
    {
      let name = namesArray[ n ];
      let o2 = _.mapExtend( null, o );
      o2.propName = name;
      let delcared = _.accessor._forbidSingle( o2 );
      if( declared )
      {
        o.names[ name ] = declared;
        result.push( declared );
      }
    }

    return result;
  }

}

var defaults = forbid_body.defaults =
{

  ... declareMultiple.body.defaults,

  preservingValue : 0,
  enumerable : 0,
  combining : 'rewrite',
  writable : true,
  message : null,

  prime : 0,
  strict : 0,

}

let forbid = _.routineUnite( declareMultiple_head, forbid_body );

//

function _forbidSingle()
{
  let o = _.routineOptions( _forbidSingle, arguments );
  let messageLine = o.protoName + o.propName + ' : ' + o.message;

  _.assert( _.strIs( o.protoName ) );
  _.assert( _.objectIs( o.methods ) );

  /* */

  let propertyDescriptor = _.prototype.propertyDescriptorActiveGet( o.object, o.propName );
  if( propertyDescriptor.descriptor )
  {
    _.assert( _.strIs( o.combining ), 'forbid : if accessor overided expect ( o.combining ) is', _.accessor.Combining.join() );

    if( _.routineIs( propertyDescriptor.descriptor.get ) && propertyDescriptor.descriptor.get.name === 'forbidden' )
    {
      return false;
    }

  }

  /* */

  if( !Object.isExtensible( o.object ) )
  {
    return false;
  }

  o.methods = null;
  o.suite = Object.create( null );
  o.suite.grab = forbidden;
  o.suite.get = forbidden;
  o.suite.put = forbidden;
  o.suite.set = forbidden;
  forbidden.isForbid = true;

  /* */

  if( o.prime )
  {

    _.assert( 0, 'not tested' );
    let o2 = _.mapExtend( null, o );
    o2.names = o.propName;
    o2.object = null;
    delete o2.protoName;
    delete o2.propName;

    _.accessor._register
    ({
      proto : o.object,
      name : o.propName,
      declaratorName : 'forbid',
      declaratorArgs : [ o2 ],
      combining : o.combining,
    });

  }

  _.assert( !o.strict );
  _.assert( !o.prime );

  o.strict = 0;
  o.prime = 0;

  let o2 = _.mapOnly( o, _.accessor.declare.body.defaults );
  o2.name = o.propName;
  delete o2.names;
  return _.accessor.declareSingle.body( o2 );

  /* */

  function forbidden()
  {
    debugger;
    throw _.err( messageLine );
  }

}

var defaults = _forbidSingle.defaults =
{
  ... forbid.defaults,
  propName : null,
  protoName : null,
}

//

/**
 * Checks if source object( object ) has own property( name ) and its forbidden.
 * @param {Object} object - source object
 * @param {String} name - name of the property
 *
 * @example
 * let Self = ClassName;
function ClassName( o ) { };
 * _.accessor.forbid( Self, { a : 'a' } );
 * _.accessor.ownForbid( Self, 'a' ) // returns true
 * _.accessor.ownForbid( Self, 'b' ) // returns false
 *
 * @function ownForbid
 * @namespace Tools.accessor
 */

function ownForbid( object, name )
{
  if( !Object.hasOwnProperty.call( object, name ) )
  return false;

  let descriptor = Object.getOwnPropertyDescriptor( object, name );
  if( _.routineIs( descriptor.get ) && descriptor.get.isForbid )
  {
    return true;
  }
  else
  {
    return false;
  }

}

// --
// etc
// --

/**
 * @summary Declares read-only accessor( s ).
 * @description Expects two arguments: (object), (names) or single as options map {@link module:Tools/base/Proto.wTools.accessor~AccessorOptions}
 *
 * @param {Object} object - target object
 * @param {Object} names - contains names of properties that will get read-only accessor
 *
 * @example
 * var Alpha = function _Alpha(){}
 * _.classDeclare
 * ({
 *   cls : Alpha,
 *   parent : null,
 *   extend : { Composes : { a : null } }
 * });
 * _.accessor.readOnly( Alpha.prototype,{ a : 'a' });
 *
 * @function forbid
 * @namespace Tools.accessor
 */

function readOnly_body( o )
{
  _.assertRoutineOptions( readOnly_body, arguments );
  _.assert( _.boolLikeFalse( o.writable ) );
  return _.accessor.declare.body( o );
}

var defaults = readOnly_body.defaults = _.mapExtend( null, declareMultiple.body.defaults );
defaults.writable = false;
// defaults.readOnly = true;

let readOnly = _.routineUnite( declareMultiple_head, readOnly_body );

//

let AccessorExtension =
{

  // getter / setter generator

  _propertyGetterSetterNames,
  _optionsNormalize,
  _asuiteForm,
  _asuiteUnfunct,
  _amethodUnfunct,
  _objectMethodsNamesGet,
  _objectMethodsGet,
  _objectMethodsValidate,
  _objectMethodMoveGet,

  // _objectPreserveValue,
  _objectSetValue,
  _objectAddMethods,
  _objectInitStorage,

  _amethodFunctor,
  _amethodFromMove,
  _moveItMake,

  // declare

  _register,
  declareSingle,
  declareMultiple,
  declare : declareMultiple,

  // forbid

  forbid,
  _forbidSingle,
  ownForbid,

  // etc

  readOnly,

  // fields

  Combining,
  AmethodTypes,
  AmethodTypesMap,
  AccessorFieldsMap,
  AccessorDefaults,
  AccessorPreferences,

}

//

let ToolsExtension =
{
}

// --
// extend
// --

_.accessor = _.accessor || Object.create( null );
_.mapSupplement( _, ToolsExtension );
_.mapExtend( _.accessor, AccessorExtension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();