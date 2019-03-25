package sgo.datos;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

import sgo.entidad.Estacion;
import sgo.utilidades.Utilidades;

public class EstacionMapper2 implements RowMapper<Estacion> {
	
	public Estacion mapRow(ResultSet rs, int arg1) throws SQLException 
	{
		Estacion eEstacion = null;
		
		try {
			
			eEstacion = new Estacion();
			eEstacion.setId(rs.getInt("id_estacion"));
			eEstacion.setNombre(Utilidades.cleanXSS(rs.getString("nombre")));
			
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		return eEstacion;
	}
}