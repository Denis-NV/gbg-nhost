SET check_function_bodies = false;
CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.customer (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    delivery_start_time time without time zone,
    delivery_end_time time without time zone,
    district_id uuid,
    is_active boolean DEFAULT true NOT NULL
);
COMMENT ON TABLE public.customer IS 'Restaurants and shops placing orders';
CREATE TABLE public.delivery_method (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL
);
CREATE TABLE public.department (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL
);
COMMENT ON TABLE public.department IS 'Production area or type';
CREATE TABLE public.district (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public."order" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    customer_id uuid NOT NULL,
    delivery_date date NOT NULL,
    delivery_method_id uuid,
    comment text,
    order_nr integer NOT NULL
);
COMMENT ON TABLE public."order" IS 'Customer orders';
CREATE SEQUENCE public.order_order_nr_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.order_order_nr_seq OWNED BY public."order".order_nr;
CREATE TABLE public.order_product (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity integer DEFAULT 1 NOT NULL
);
COMMENT ON TABLE public.order_product IS 'Bridge table for orders and products many-to-many relationship';
CREATE TABLE public.product (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    department_id uuid,
    weight numeric NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);
ALTER TABLE ONLY public."order" ALTER COLUMN order_nr SET DEFAULT nextval('public.order_order_nr_seq'::regclass);
ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.delivery_method
    ADD CONSTRAINT delivery_method_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.district
    ADD CONSTRAINT district_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_order_nr_key UNIQUE (order_nr);
ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.order_product
    ADD CONSTRAINT order_product_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_delivery_method_updated_at BEFORE UPDATE ON public.delivery_method FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_delivery_method_updated_at ON public.delivery_method IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_department_updated_at BEFORE UPDATE ON public.department FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_department_updated_at ON public.department IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_district_updated_at BEFORE UPDATE ON public.district FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_district_updated_at ON public.district IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_order_product_updated_at BEFORE UPDATE ON public.order_product FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_order_product_updated_at ON public.order_product IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_order_updated_at BEFORE UPDATE ON public."order" FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_order_updated_at ON public."order" IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_product_updated_at BEFORE UPDATE ON public.product FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_product_updated_at ON public.product IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.district(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_delivery_method_id_fkey FOREIGN KEY (delivery_method_id) REFERENCES public.delivery_method(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.order_product
    ADD CONSTRAINT order_product_order_id_fkey FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.order_product
    ADD CONSTRAINT order_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id) ON UPDATE CASCADE ON DELETE SET NULL;
