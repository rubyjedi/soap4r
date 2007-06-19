enum.xsd ........ original definition
enumsample.rb ... generated class definition

run xsd2ruby.rb to get enumsample.rb from enum.xsd

% xsd2ruby.rb --xsd enum.xsd --classdef --mapping_registry --mapper --force
