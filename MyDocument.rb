#
#  MyDocument.rb
#  MovaX
#
#  Created by Andrei Popov on 7/24/06.
#  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
#


require 'osx/cocoa'
require 'osx/coredata'

class MyDocument < OSX:: NSPersistentDocument

  ns_overrides 'windowNibName', 'windowControllerDidLoadNib:',
    'setManagedObjectContext:'

  @@model_registered = false

  def windowNibName
    return "MyDocument"
  end

  def windowControllerDidLoadNib (aController)
    super_windowControllerDidLoadNib(aController)
    # user interface preparation code
  end

  # define accessors for properties of models
  def setManagedObjectContext(context)
    super_setManagedObjectContext(context)
    unless @@model_registered
      OSX::CoreData.define_wrapper(managedObjectModel)
      @@model_registered = true
    end
  end

end
