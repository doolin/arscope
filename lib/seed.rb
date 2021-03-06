# frozen_string_literal: true

bessie = Animal.create(kind: 'cow', breed: 'holstein', name: 'Bessie', role: 'working', last_vet: 2.years.ago)
shredder = Animal.create(kind: 'goat', breed: '', name: 'Shredder', role: 'pet', last_vet: 2.years.ago)
rover = Animal.create(kind: 'dog', breed: 'holstein', name: 'Rover', role: 'working', last_vet: 6.months.ago)
wheezie = Animal.create(kind: 'cat', breed: 'maine coon', name: 'Wheezie', role: 'pet', last_vet: 6.months.ago)
tabby = Animal.create(kind: 'cat', breed: 'tabby') # stray
sallie = Animal.create(kind: 'mule', name: 'Sallie', role: 'working', last_vet: 2.years.ago)
sku1 = Animal.create(kind: 'cow', breed: 'angus', role: 'stock', last_vet: 2.years.ago, sku: 1)
sku2 = Animal.create(kind: 'bull', breed: 'angus', role: 'stock', last_vet: 6.months.ago, sku: 2)
_funny_farm = Farm.create(name: 'Funny', animals: [bessie, shredder, rover, wheezie, sallie, sku1, sku2, tabby], location: 'moon')
