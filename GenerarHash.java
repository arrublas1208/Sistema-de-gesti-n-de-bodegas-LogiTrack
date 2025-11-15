import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class GenerarHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        String password = "admin123";
        String hash = encoder.encode(password);

        System.out.println("========================================");
        System.out.println("HASH BCRYPT GENERADO");
        System.out.println("========================================");
        System.out.println("Contraseña: " + password);
        System.out.println("Hash: " + hash);
        System.out.println("");
        System.out.println("SQL para actualizar:");
        System.out.println("UPDATE usuario SET password = '" + hash + "' WHERE username = 'admin';");
    }
}
