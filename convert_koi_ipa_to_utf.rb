#! /opt/local/bin/ruby -w

# convert_koi_ipa_to_utf.rb
# MovaX
#
# Created by Andrei Popov on 7/25/06.
# Copyright 2006 Andrei Popov (andrei@ceesaxp.org). All rights reserved.

# This script will convert KOI8-encoded Mueller dictionary to UNICODE (UTF-8) one, preserving IPA pronounciation symbols.  Results will be dumped into an XML file with record structured as:
# <dictionaryRecord>
#   <term>word</term>
#   <pronounciation>word</pronounciation>
#   <definitions>
#     <definition order="1" partOfSpeech="noun">word definition and examples follow</definition>
#     <definition order="2" partOfSpeech="adjective">word definition and examples follow</definition>
#   </definition>
# </dictionaryRecord>
#
require "iconv"

convertKOI2UTF = Iconv.new("UTF-8", "KOI8-R")

$stdin.each { |line|
  line.scan(/^([-'[:alpha:]]+)  (.+)$/) { |theWord, translations|
    translations.split(/_I+/).each { |aTranslation|
      aTranslation.scan(/\[(\S+)\] (.+)$/) { |ipa, wordDefinition|
        puts theWord + "\t" + convertKOI2UTF.iconv(wordDefinition)
      }
    }
  }
}

