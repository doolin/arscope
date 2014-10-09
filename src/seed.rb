bessie = Animal.create(kind: 'cow', name: 'Bessie', role: 'working', last_vet: 2.years.ago)
shredder = Animal.create(kind: 'goat', name: 'Shredder', role: 'pet', last_vet: 2.years.ago)
rover = Animal.create(kind: 'dog', name: 'Rover', role: 'working', last_vet: 6.months.ago)
wheezie = Animal.create(kind: 'cat', name: 'Wheezie', role: 'pet', last_vet: 6.months.ago)
sallie = Animal.create(kind: 'mule', name: 'Sallie', role: 'working', last_vet: 2.years.ago)
sku1 = Animal.create(kind: 'cow', role: 'stock', last_vet: 2.years.ago, sku: 1)
sku2 = Animal.create(kind: 'bull', role: 'stock', last_vet: 6.months.ago, sku: 2)
funny_farm = Farm.create(name: "Funny", animals: [bessie, shredder, rover, wheezie, sallie, sku1, sku2], location: 'moon')
# funny_farm.save!
