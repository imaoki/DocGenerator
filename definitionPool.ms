/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
global docGeneratorDefinitionPool = Dictionary #String
/* 依存無し */
::docGeneratorDefinitionPool[@"DocDependentTable.ms"] = fileIn @"DocDependentTable.ms"
::docGeneratorDefinitionPool[@"DocOptions.ms"] = fileIn @"DocOptions.ms"
/*
DocOptions.ms
*/
::docGeneratorDefinitionPool[@"DocPathMaker.ms"] = fileIn @"DocPathMaker.ms"
::docGeneratorDefinitionPool[@"DocRender.ms"] = fileIn @"DocRender.ms"

/* 依存無し */
::docGeneratorDefinitionPool[@"Parser\DocComment.ms"] = fileIn @"Parser\DocComment.ms"
::docGeneratorDefinitionPool[@"Parser\PathNameLiteral.ms"] = fileIn @"Parser\PathNameLiteral.ms"
::docGeneratorDefinitionPool[@"Parser\StringLiteral.ms"] = fileIn @"Parser\StringLiteral.ms"
/*
PathNameLiteral.ms
StringLiteral.ms
*/
::docGeneratorDefinitionPool[@"Parser\DocDependent.ms"] = fileIn @"Parser\DocDependent.ms"
/*
DocComment.ms
PathNameLiteral.ms
StringLiteral.ms
*/
::docGeneratorDefinitionPool[@"Parser\Doc.ms"] = fileIn @"Parser\Doc.ms"

::docGeneratorDefinitionPool
