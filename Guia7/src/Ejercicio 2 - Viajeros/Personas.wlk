
class Persona {

	var viajes = #{}
	
	method agregarViaje(_unViaje){ viajes.add(_unViaje) }
	method quitarViaje(_unViaje){ viajes.remove(_unViaje)}
	
	/* En qué países estuvo una persona en un determinado año. Son: los países de los
	viajes que hizo la persona, más los países en donde residió en ese año */
	method enQuePaisesEstuvo(_unAnio)
	
	/* Dada una persona, si coincidió con otra en un determinado año, o sea, si hay al
	menos un país en el que los dos estuvieron en ese año */
	method coincidioCon(_unaPersona, _unAnio){
		return self.enQuePaisesEstuvo(_unAnio).any({pais => _unaPersona.enQuePaisesEstuvo(_unAnio).contains(pais)})
	}
	
	
	method viajesEnElAnio(_unAnio){// retorna una Lista con los viajes de ese año realizados por la persona
		
		return viajes.filter({viaje => viaje.anio() == _unAnio})
	}
	
	method paisesDeLosViajes(_unosViajes){// recibe una lista y devuelve otra con los nombres de los paises de cada viaje
		
		return _unosViajes.map({viaje => viaje.pais()})
		
	}

}

//======================= TIPOS DE PERSONAS ====================

/** Establecido: se sabe en qué país vive, en cualquier año que se pregunte, residió en
ese país y en ningún otro */
class Establecido inherits Persona {
	
	var residencia
	
	constructor(_residencia){
		
		residencia = _residencia
		
	}
	
	method residencia() = residencia
	method residenciaEnUnConjunto(){//para que sea polimorfico con el menor
		var r = #{}
		r.add(residencia)
		
		return r
	}
	/** redefinicion del los metodos */
	override method enQuePaisesEstuvo(_unAnio){
		
		return self.paisesDeLosViajes(self.viajesEnElAnio(_unAnio)).addAll(self.residenciaEnUnConjunto())
	}
	
}

/** Migrante: se sabe en qué país nació, a qué país se mudó, y en qué año. Hasta el año
antes de mudarse, residió en el país en el que nació. Después de mudarse, residió
en el país al que se mudó. El año en que se mudó residió en los dos */
class Migrante inherits Persona {
	
	var nacidoEn
	var residencia
	var anioMudanza = 2017 //inicializado en el presente
	
	constructor(_nacidoEn){
		
		nacidoEn = _nacidoEn
		residencia = _nacidoEn	
	}
	
	method nacidoEn() = nacidoEn
	method residencia() = residencia
	method anioMudanza() = anioMudanza
	
	method mudarse(_lugar, _anio){
		
		residencia = _lugar
		anioMudanza = _anio
		
	}
	
	method residenciaEnElAnio(_unAnio){//retorna un conjunto con los paises en que estubo ese año.MEJORAR ESTE METODO !!!
		
		var r = #{}
		if (_unAnio == self.anioMudanza()){
			r.add(self.residencia())
			r.add(self.nacidoEn())
		}
		else if(_unAnio <= self.anioMudanza() - 1){
			
			r.add(self.nacidoEn())
		}
		else{
			r.add(self.residencia())
		}
		
		return r
	}
	
	override method enQuePaisesEstuvo(_unAnio){
		
		return self.paisesDeLosViajes(self.viajesEnElAnio(_unAnio)).addAll(self.residenciaEnElAnio(_unAnio))
	}
	
}

/** Doctor : se sabe en qué país vive, en qué país hizo el doctorado, y entre qué años.
P.ej. si Juan, que vive en Brasil, hizo el doctorado en Colombia entre 2008 y 2011,
entonces residió en Colombia esos 4 años, y en Brasil hasta 2008 inclusive, y a
partir de 2011 (para 2009 y 2010, residió todo el año en Colombia). */
class Doctor inherits Persona {
	
	var residencia
	var paisDondeDoctoro
	var inicioDoctorado = 0
	var finDoctorado = 0
	
	//=============== CONSTRUCTORES =================
	/*constructor(_residencia){
		
		residencia = _residencia
		
	}
	constructor(_residencia,_seDoctoroEn) = self(_residencia){
		
		paisDondeDoctoro = _seDoctoroEn  
	} */
	
	constructor(_residencia,_seDoctoroEn,_anioInicio,_anioFin){ //= self(_residencia,_seDoctoroEn)
		
		residencia = _residencia
		paisDondeDoctoro = _seDoctoroEn
		inicioDoctorado = _anioInicio
		finDoctorado = _anioFin
		
	}
	
	method residencia() = residencia
	method paisDondeDoctoro() = paisDondeDoctoro
	method inicioDoctorado() = inicioDoctorado
	method finDoctorado() = finDoctorado
	
	override method enQuePaisesEstuvo(_unAnio){
		
		return self.paisesDeLosViajes(self.viajesEnElAnio(_unAnio)).addAll(self.residenciaEnElAnio(_unAnio))
	}
	
	method residenciaEnElAnio(_unAnio){
		var r = #{}
		if (_unAnio.beetwen(self.inicioDoctorado(), self.finDoctorado()) ){
			r.add(self.paisDondeDoctoro())
		}
		else if(_unAnio == self.inicioDoctorado() or _unAnio == self.finDoctorado()){
			r.add(self.residencia())
			r.add(self.paisDondeDoctoro())
		}
		else
			r.add(self.residencia())
			
		return r
	}
	
}

/** Menor : se sabe quién es la madre. Reside, en cualquier año, en los mismos paises
que la madre. OJO los viajes del menor son separados, si viajaron juntos, hay
que cargar el viaje en los dos, solamente se considera que coinciden los países de
residencia */
class Menor inherits Persona {
	
	var madre
	
	constructor(_madre){
		madre = _madre
	}
	
	method residencia(){
		return madre.residencia()
	}
	
	override method enQuePaisesEstuvo(_unAnio){
		
		return self.paisesDeLosViajes(self.viajesEnElAnio(_unAnio)).addAll(self.residenciaEnElAnio(_unAnio))
	}
	
	method residenciaEnElAnio(_unAnio){
		return madre.residenciaEnElAnio(_unAnio)
	}
	
}