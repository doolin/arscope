bessie = Animal.create(kind: 'cow', name: 'Bessie', role: 'working', last_vet: 2.years.ago)
shredder = Animal.create(kind: 'goat', name: 'Shredder', role: 'pet', last_vet: 2.years.ago)
rover = Animal.create(kind: 'dog', name: 'Rover', role: 'working', last_vet: 2.years.ago)
wheezie = Animal.create(kind: 'cat', name: 'Wheezie', role: 'pet', last_vet: 2.years.ago)
sallie = Animal.create(kind: 'mule', name: 'Sallie', role: 'working', last_vet: 2.years.ago)
funny_farm = Farm.create(name: "Funny", animals: [bessie, shredder, rover, wheezie, sallie], location: 'moon')
funny_farm.save!
