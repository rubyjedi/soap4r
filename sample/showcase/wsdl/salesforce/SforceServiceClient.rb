#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = Soap.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   login(parameters)
#
# ARGS
#   parameters      Login - {urn:partner.soap.sforce.com}login
#
# RETURNS
#   parameters      LoginResponse - {urn:partner.soap.sforce.com}loginResponse
#
# RAISES
#   #   fault           LoginFault - {urn:fault.partner.soap.sforce.com}LoginFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.login(parameters)

# SYNOPSIS
#   describeSObject(parameters)
#
# ARGS
#   parameters      DescribeSObject - {urn:partner.soap.sforce.com}describeSObject
#
# RETURNS
#   parameters      DescribeSObjectResponse - {urn:partner.soap.sforce.com}describeSObjectResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.describeSObject(parameters)

# SYNOPSIS
#   describeGlobal(parameters)
#
# ARGS
#   parameters      DescribeGlobal - {urn:partner.soap.sforce.com}describeGlobal
#
# RETURNS
#   parameters      DescribeGlobalResponse - {urn:partner.soap.sforce.com}describeGlobalResponse
#
# RAISES
#   #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.describeGlobal(parameters)

# SYNOPSIS
#   describeLayout(parameters)
#
# ARGS
#   parameters      DescribeLayout - {urn:partner.soap.sforce.com}describeLayout
#
# RETURNS
#   parameters      DescribeLayoutResponse - {urn:partner.soap.sforce.com}describeLayoutResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.describeLayout(parameters)

# SYNOPSIS
#   create(parameters)
#
# ARGS
#   parameters      Create - {urn:partner.soap.sforce.com}create
#
# RETURNS
#   parameters      CreateResponse - {urn:partner.soap.sforce.com}createResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.create(parameters)

# SYNOPSIS
#   update(parameters)
#
# ARGS
#   parameters      Update - {urn:partner.soap.sforce.com}update
#
# RETURNS
#   parameters      UpdateResponse - {urn:partner.soap.sforce.com}updateResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.update(parameters)

# SYNOPSIS
#   delete(parameters)
#
# ARGS
#   parameters      Delete - {urn:partner.soap.sforce.com}delete
#
# RETURNS
#   parameters      DeleteResponse - {urn:partner.soap.sforce.com}deleteResponse
#
# RAISES
#   #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.delete(parameters)

# SYNOPSIS
#   retrieve(parameters)
#
# ARGS
#   parameters      Retrieve - {urn:partner.soap.sforce.com}retrieve
#
# RETURNS
#   parameters      RetrieveResponse - {urn:partner.soap.sforce.com}retrieveResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           InvalidFieldFault - {urn:fault.partner.soap.sforce.com}InvalidFieldFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.retrieve(parameters)

# SYNOPSIS
#   convertLead(parameters)
#
# ARGS
#   parameters      ConvertLead - {urn:partner.soap.sforce.com}convertLead
#
# RETURNS
#   parameters      ConvertLeadResponse - {urn:partner.soap.sforce.com}convertLeadResponse
#
# RAISES
#   #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.convertLead(parameters)

# SYNOPSIS
#   getDeleted(parameters)
#
# ARGS
#   parameters      GetDeleted - {urn:partner.soap.sforce.com}getDeleted
#
# RETURNS
#   parameters      GetDeletedResponse - {urn:partner.soap.sforce.com}getDeletedResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.getDeleted(parameters)

# SYNOPSIS
#   getUpdated(parameters)
#
# ARGS
#   parameters      GetUpdated - {urn:partner.soap.sforce.com}getUpdated
#
# RETURNS
#   parameters      GetUpdatedResponse - {urn:partner.soap.sforce.com}getUpdatedResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.getUpdated(parameters)

# SYNOPSIS
#   query(parameters)
#
# ARGS
#   parameters      Query - {urn:partner.soap.sforce.com}query
#
# RETURNS
#   parameters      QueryResponse - {urn:partner.soap.sforce.com}queryResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           InvalidFieldFault - {urn:fault.partner.soap.sforce.com}InvalidFieldFault, #   fault           MalformedQueryFault - {urn:fault.partner.soap.sforce.com}MalformedQueryFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.query(parameters)

# SYNOPSIS
#   queryMore(parameters)
#
# ARGS
#   parameters      QueryMore - {urn:partner.soap.sforce.com}queryMore
#
# RETURNS
#   parameters      QueryMoreResponse - {urn:partner.soap.sforce.com}queryMoreResponse
#
# RAISES
#   #   fault           InvalidQueryLocatorFault - {urn:fault.partner.soap.sforce.com}InvalidQueryLocatorFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.queryMore(parameters)

# SYNOPSIS
#   search(parameters)
#
# ARGS
#   parameters      Search - {urn:partner.soap.sforce.com}search
#
# RETURNS
#   parameters      SearchResponse - {urn:partner.soap.sforce.com}searchResponse
#
# RAISES
#   #   fault           InvalidSObjectFault - {urn:fault.partner.soap.sforce.com}InvalidSObjectFault, #   fault           InvalidFieldFault - {urn:fault.partner.soap.sforce.com}InvalidFieldFault, #   fault           MalformedSearchFault - {urn:fault.partner.soap.sforce.com}MalformedSearchFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.search(parameters)

# SYNOPSIS
#   getServerTimestamp(parameters)
#
# ARGS
#   parameters      GetServerTimestamp - {urn:partner.soap.sforce.com}getServerTimestamp
#
# RETURNS
#   parameters      GetServerTimestampResponse - {urn:partner.soap.sforce.com}getServerTimestampResponse
#
# RAISES
#   #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.getServerTimestamp(parameters)

# SYNOPSIS
#   setPassword(parameters)
#
# ARGS
#   parameters      SetPassword - {urn:partner.soap.sforce.com}setPassword
#
# RETURNS
#   parameters      SetPasswordResponse - {urn:partner.soap.sforce.com}setPasswordResponse
#
# RAISES
#   #   fault           InvalidIdFault - {urn:fault.partner.soap.sforce.com}InvalidIdFault, #   fault           InvalidNewPasswordFault - {urn:fault.partner.soap.sforce.com}InvalidNewPasswordFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.setPassword(parameters)

# SYNOPSIS
#   resetPassword(parameters)
#
# ARGS
#   parameters      ResetPassword - {urn:partner.soap.sforce.com}resetPassword
#
# RETURNS
#   parameters      ResetPasswordResponse - {urn:partner.soap.sforce.com}resetPasswordResponse
#
# RAISES
#   #   fault           InvalidIdFault - {urn:fault.partner.soap.sforce.com}InvalidIdFault, #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.resetPassword(parameters)

# SYNOPSIS
#   getUserInfo(parameters)
#
# ARGS
#   parameters      GetUserInfo - {urn:partner.soap.sforce.com}getUserInfo
#
# RETURNS
#   parameters      GetUserInfoResponse - {urn:partner.soap.sforce.com}getUserInfoResponse
#
# RAISES
#   #   fault           UnexpectedErrorFault - {urn:fault.partner.soap.sforce.com}UnexpectedErrorFault
#
parameters = nil
puts obj.getUserInfo(parameters)


