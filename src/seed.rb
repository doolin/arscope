bessie = Animal.create(kind: 'cow', name: 'Bessie')
shredder = Animal.create(kind: 'goat', name: 'Shredder')
rover = Animal.create(kind: 'dog', name: 'Rover')
wheezie = Animal.create(kind: 'cat', name: 'Wheezie')
funny_farm = Farm.create(name: "Funny", animals: [bessie, shredder, rover, wheezie], location: 'moon')
funny_farm.save!
