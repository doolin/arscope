bessie = Animal.create(kind: 'cow', name: 'Bessie')
Animal.create(kind: 'goat', name: 'Shredder')
Animal.create(kind: 'dog', name: 'Rover')
Animal.create(kind: 'cat', name: 'Wheezie')
Farm.create(name: "Funny", animals: [bessie])
