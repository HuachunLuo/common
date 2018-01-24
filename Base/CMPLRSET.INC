{$DEFINE DEBUG}

{$DEFINE CMPLRSET_LOADED}

{$IFDEF VER130}
  {$DEFINE DELPHI5}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI5_DOWN}
  {$DEFINE DELPHI6_DOWN}
  {$DEFINE DELPHI7_DOWN}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE DELPHI6}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_DOWN}
  {$DEFINE DELPHI7_DOWN}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE DELPHI7}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI7_DOWN}
{$ENDIF}

{$IMPLICITBUILD ON} // package rebuild all (default ON)
{$A+} // ALIGN
{$B-} // BOOLEVAL
{$G+} // IMPORTEDDATA, use other pkg's vars
{$L+} // LONGSTRINGS
{$O+} // OPTIMAIZATION

{$IFDEF DEBUG}

{$HINTS ON}
{$U+} // SAFEDIVIDE
{$C+} // ASSERTIONS
{$D+} // DEBUGINFO
{$L+} // LOCALSYMBOLS
{$Q+} // OVERFLOWCHECKS
{$R+} // RANGECHECKS
{$WARNINGS ON}
{$Y+} // REFERENCEINFO
{$I+} // IOCHECKS

{$ELSE}

{$HINTS ON}
{$U-} // SAFEDIVIDE
{$C-} // ASSERTIONS
{$D-} // DEBUGINFO
{$L-} // LOCALSYMBOLS
{$Q-} // OVERFLOWCHECKS
{$R-} // RANGECHECKS
{$WARNINGS ON}
{$Y-} // REFERENCEINFO
{$I-} // IOCHECKS OFF, call IOResult

{$ENDIF}


// notes
// {$RUNONLY ON} // pkg runtime only
// {$DENYPACKAGEUNIT ON} // pkg only
// {$WEAKPACKAGEUNIT ON} // pkg only
// {$DESCRIPTION 'Software'}
// {$DESIGNONLY OFF} // pkg only
// {$E extension} // extension name, often for resource dll
// {$IFOPT switch}
// {$IMAGEBASE $40000000} // $40000000 to $7FFFFFFF
// {$WRITEABLECONST ON} // {$J+}
// {$LINK filename} // {$L fn}
// {$M minstacksize,maxstacksize} // MAXSTACKSIZE, MAXSTACKSIZE // def 16384,1048576 // only in program
// {$MINENUMSIZE 1} // {$Z1}
// {$NODEFINE identifier}
// {$NOINCLUDE filename}
// {$RESOURCE filename} // {$R fn}
// {$STACKFRAMES OFF} {$W-}
// {$TYPEDADDRESS OFF} {$T-}
// {$TYPEINFO OFF} {$M-}
// {$EXTENDEDSYNTAX ON} // {$X+}


